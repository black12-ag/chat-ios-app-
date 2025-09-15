//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

public import Contacts
import CryptoKit
import Foundation
import LibMunrChatClient

extension Notification.Name {
    public static let OWSContactsManagerMunrChatAccountsDidChange = Notification.Name("OWSContactsManagerMunrChatAccountsDidChangeNotification")
    public static let OWSContactsManagerContactsDidChange = Notification.Name("OWSContactsManagerContactsDidChangeNotification")
}

@objc
public enum RawContactAuthorizationStatus: UInt {
    case notDetermined, denied, restricted, limited, authorized
}

public enum ContactAuthorizationForEditing {
    // Contact edit access not supported by this device (e.g. a linked device)
    case notAllowed
    // Contact edit access explicitly denied by user
    case notAuthorized
    // Contact read access explicitly allowed by user to some or all of the system contacts.
    // In both of these situations, the user can write to system contacts.
    case authorized
}

public enum ContactAuthorizationForSyncing {
    // Contact edit access not supported by this device (e.g. a linked device)
    case notAllowed
    // Contact edit access explicitly denied by user
    case denied
    // Contact access restricted by actions outside the control of the user (see CNAuthorizationStatus.restricted)
    case restricted
    // Contact read access explicitly allowed by user to all of the system contacts.
    case authorized
    // Contact read access explicitly allowed by user to some of the system contacts.
    case limited
}

public enum ContactAuthorizationForSharing {
    // Authorization hasn't yet been requested
    case notDetermined
    // Contact read access explicitly denied by user
    case denied
    // Some type of contact read access explicitly allowed by user
    case authorized
}

public class OWSContactsManager: NSObject, ContactsManagerProtocol {
    private let cnContactCache = LRUCache<String, CNContact>(maxSize: 50, shouldEvacuateInBackground: true)
    private let systemContactsCache = SystemContactsCache()

    private let addressesAllowingAvatarDownloadCache = AtomicSet<MunrChatServiceAddress>(lock: .init())
    private let groupIdsAllowingAvatarDownloadCache = AtomicSet<Data>(lock: .init())
    private let addressesNotNeedingLowTrustWarningCache = AtomicSet<MunrChatServiceAddress>(lock: .init())
    private let groupIdsNotNeedingLowTrustWarningCache = AtomicSet<Data>(lock: .init())

    private let intersectionQueue = DispatchQueue(label: "org.MunrChat.contacts.intersection")

    private let keyValueStore = KeyValueStore(collection: "OWSContactsManagerCollection")
    private let serviceIdsExplicitlyAllowingAvatarDownloadsStore = KeyValueStore(collection: "OWSContactsManager.skipContactAvatarBlurByUuidStore")
    private let groupIdsExplicitlyAllowingAvatarDownloadsStore = KeyValueStore(collection: "OWSContactsManager.skipGroupAvatarBlurByGroupIdStore")

    private let avatarAddressesBeingDownloaded = AtomicSet<MunrChatServiceAddress>(lock: .init())
    private let avatarGroupIdsBeingDownloaded = AtomicSet<Data>(lock: .init())
    public let avatarAddressesToShowDownloadingSpinner = AtomicSet<MunrChatServiceAddress>(lock: .init())
    public let avatarGroupIdsToShowDownloadingSpinner = AtomicSet<Data>(lock: .init())

    private let nicknameManager: any NicknameManager
    private let recipientDatabaseTable: RecipientDatabaseTable
    private let systemContactsFetcher: SystemContactsFetcher
    private let usernameLookupManager: UsernameLookupManager

    public var isEditingAllowed: Bool {
        // We're only allowed to edit contacts on devices that can sync them. Otherwise the UX doesn't make sense.
        return isSyncingAllowed
    }

    public var isSyncingAllowed: Bool {
        let tsAccountManager = DependenciesBridge.shared.tsAccountManager
        return tsAccountManager.registrationStateWithMaybeSneakyTransaction.isPrimaryDevice ?? false
    }

    /// Must call `requestSystemContactsOnce` before accessing this method
    public var editingAuthorization: ContactAuthorizationForEditing {
        guard isEditingAllowed else {
            return .notAllowed
        }
        switch systemContactsFetcher.rawAuthorizationStatus {
        case .notDetermined:
            owsFailDebug("should have called `requestOnce` before checking authorization status.")
            fallthrough
        case .denied, .restricted:
            return .notAuthorized
        case .authorized, .limited:
            return .authorized
        }
    }

    /// Must call `requestSystemContactsOnce` before accessing this method
    public var syncingAuthorization: ContactAuthorizationForSyncing {
        guard isSyncingAllowed else {
            return .notAllowed
        }
        switch systemContactsFetcher.rawAuthorizationStatus {
        case .notDetermined:
            owsFailDebug("should have called `requestOnce` before checking authorization status.")
            fallthrough
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .limited:
            return .limited
        case .authorized:
            return .authorized
        }
    }

    public var sharingAuthorization: ContactAuthorizationForSharing {
        switch self.systemContactsFetcher.rawAuthorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .denied, .restricted:
            return .denied
        case .authorized, .limited:
            return .authorized
        }
    }
    /// Whether or not we've fetched system contacts on this launch.
    ///
    /// This property is set to true even if the user doesn't have any system
    /// contacts.
    ///
    /// This property is only valid if the user has granted contacts access.
    /// Otherwise, it's value is undefined.
    public private(set) var hasLoadedSystemContacts: Bool = false

    public init(
        appReadiness: AppReadiness,
        nicknameManager: any NicknameManager,
        recipientDatabaseTable: RecipientDatabaseTable,
        usernameLookupManager: any UsernameLookupManager
    ) {
        self.nicknameManager = nicknameManager
        self.recipientDatabaseTable = recipientDatabaseTable
        self.systemContactsFetcher = SystemContactsFetcher(appReadiness: appReadiness)
        self.usernameLookupManager = usernameLookupManager
        super.init()
        self.systemContactsFetcher.delegate = self
        SwiftSingletons.register(self)

        appReadiness.runNowOrWhenAppDidBecomeReadySync {
            self.setupNotificationObservations()
        }
    }

    private func setupNotificationObservations() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.profileWhitelistDidChange(notification:)),
            name: UserProfileNotifications.profileWhitelistDidChange,
            object: nil
        )
    }

    // Request systems contacts and start syncing changes. The user will see an alert
    // if they haven't previously.
    public func requestSystemContactsOnce(completion: (((any Error)?) -> Void)? = nil) {
        AssertIsOnMainThread()

        guard isSyncingAllowed else {
            if let completion = completion {
                Logger.warn("Editing contacts isn't available on linked devices.")
                completion(OWSError.makeGenericError())
            }
            return
        }
        systemContactsFetcher.requestOnce(completion: completion)
    }

    /// Ensure's the app has the latest contacts, but won't prompt the user for contact
    /// access if they haven't granted it.
    public func fetchSystemContactsOnceIfAlreadyAuthorized() {
        guard isSyncingAllowed else {
            return
        }
        systemContactsFetcher.fetchOnceIfAlreadyAuthorized()
    }

    /// This variant will fetch system contacts if contact access has already been granted,
    /// but not prompt for contact access. Also, it will always notify delegates, even if
    /// contacts haven't changed, and will clear out any stale cached MunrChatAccounts
    public func userRequestedSystemContactsRefresh() -> Promise<Void> {
        guard isSyncingAllowed else {
            owsFailDebug("Editing contacts isn't available on linked devices.")
            return Promise<Void>(error: OWSError.makeAssertionError())
        }
        return Promise<Void> { future in
            self.systemContactsFetcher.userRequestedRefresh { error in
                if let error {
                    Logger.error("refreshing contacts failed with error: \(error)")
                    future.reject(error)
                } else {
                    future.resolve(())
                }
            }
        }
    }
}

// MARK: - SystemContactsFetcherDelegate

extension OWSContactsManager: SystemContactsFetcherDelegate {

    func systemContactsFetcher(_ systemContactsFetcher: SystemContactsFetcher, hasAuthorizationStatus authorizationStatus: RawContactAuthorizationStatus) {
        guard isEditingAllowed else {
            owsFailDebug("Syncing contacts isn't available on linked devices.")
            return
        }
        switch authorizationStatus {
        // TODO: [Contacts, iOS 18] Validate if limited contacts authorization is appropriate
        case .restricted, .denied, .limited:
            self.updateContacts(nil, isUserRequested: false)
        case .notDetermined, .authorized:
            break
        }
    }

    func systemContactsFetcher(_ systemContactsFetcher: SystemContactsFetcher, updatedContacts contacts: [SystemContact], isUserRequested: Bool) {
        guard isEditingAllowed else {
            owsFailDebug("Syncing contacts isn't available on linked devices.")
            return
        }
        updateContacts(contacts, isUserRequested: isUserRequested)
    }

    public func displayNameString(for address: MunrChatServiceAddress, transaction: DBReadTransaction) -> String {
        displayName(for: address, tx: transaction).resolvedValue()
    }

    public func shortDisplayNameString(for address: MunrChatServiceAddress, transaction: DBReadTransaction) -> String {
        displayName(for: address, tx: transaction).resolvedValue(useShortNameIfAvailable: true)
    }
}

// MARK: -

private class SystemContactsCache {
    let fetchedSystemContacts = AtomicOptional<FetchedSystemContacts>(nil, lock: .init())
}

// MARK: -

extension OWSContactsManager: ContactManager {

    // MARK: Low Trust

    public func isLowTrustContact(contactThread: TSContactThread, tx: DBReadTransaction) -> Bool {
        let address = contactThread.contactAddress

        if addressesNotNeedingLowTrustWarningCache.contains(address) {
            return false
        }

        if SSKEnvironment.shared.profileManagerRef.isThread(inProfileWhitelist: contactThread, transaction: tx) {
            addressesNotNeedingLowTrustWarningCache.insert(address)
            return false
        }

        if !contactThread.hasPendingMessageRequest(transaction: tx) {
            return false
        }

        if isInWhitelistedGroupsWithLocalUser(
            otherAddress: address,
            requireMultipleMutualGroups: true,
            tx: tx
        ) {
            addressesNotNeedingLowTrustWarningCache.insert(address)
            return false
        }

        return true
    }

    public func isLowTrustGroup(groupThread: TSGroupThread, tx: DBReadTransaction) -> Bool {
        if groupIdsNotNeedingLowTrustWarningCache.contains(groupThread.groupId) {
            return false
        }

        if SSKEnvironment.shared.profileManagerRef.isThread(inProfileWhitelist: groupThread, transaction: tx) {
            groupIdsNotNeedingLowTrustWarningCache.insert(groupThread.groupId)
            return false
        }

        if !groupThread.hasPendingMessageRequest(transaction: tx) {
            return false
        }
        // We can skip "unknown thread warnings" if a group has members which are trusted.
        if hasWhitelistedGroupMember(groupThread: groupThread, tx: tx) {
            groupIdsNotNeedingLowTrustWarningCache.insert(groupThread.groupId)
            return false
        }
        return true
    }

    private func isInWhitelistedGroupsWithLocalUser(
        otherAddress: MunrChatServiceAddress,
        requireMultipleMutualGroups: Bool,
        tx: DBReadTransaction
    ) -> Bool {
        guard let localAddress = DependenciesBridge.shared.tsAccountManager.localIdentifiers(tx: tx)?.aciAddress else {
            owsFailDebug("Missing localAddress.")
            return false
        }
        let otherGroupThreadIds = TSGroupThread.groupThreadIds(with: otherAddress, transaction: tx)
        guard !otherGroupThreadIds.isEmpty else {
            return false
        }
        let localGroupThreadIds = TSGroupThread.groupThreadIds(with: localAddress, transaction: tx)
        let groupThreadIds = Set(otherGroupThreadIds).intersection(localGroupThreadIds)

        var isInOneWhitelistedGroup = false
        let onlyNeedToCheckForOneMutualGroup = !requireMultipleMutualGroups

        for groupThreadId in groupThreadIds {
            guard let groupThread = TSGroupThread.anyFetchGroupThread(uniqueId: groupThreadId, transaction: tx) else {
                owsFailDebug("Missing group thread")
                continue
            }
            if SSKEnvironment.shared.profileManagerRef.isGroupId(inProfileWhitelist: groupThread.groupId, transaction: tx) {
                if isInOneWhitelistedGroup || onlyNeedToCheckForOneMutualGroup {
                    return true
                }
                isInOneWhitelistedGroup = true
            }
        }
        return false
    }

    private func hasWhitelistedGroupMember(groupThread: TSGroupThread, tx: DBReadTransaction) -> Bool {
        groupThread.groupMembership.fullMembers.contains { member in
            SSKEnvironment.shared.profileManagerRef.isUser(inProfileWhitelist: member, transaction: tx)
        }
    }

    // MARK: - Avatar Blurring

    public func didTapToUnblurAvatar(for thread: TSThread) {
        Task {
            if let contactThread = thread as? TSContactThread {
                await unblurContactAvatar(address: contactThread.contactAddress)
            } else if let groupThread = thread as? TSGroupThread {
                await unblurGroupAvatar(for: groupThread)
            } else {
                owsFailDebug("Invalid thread.")
            }
        }
    }

    private func unblurContactAvatar(
        address: MunrChatServiceAddress
    ) async {
        let db = DependenciesBridge.shared.db

        let isBlurred = db.read { tx in
            self.shouldBlurContactAvatar(address: address, tx: tx)
        }
        guard isBlurred else {
            // No need to unblur
            return
        }

        self.avatarAddressesBeingDownloaded.insert(address)

        let spinnerTask = Task { @MainActor in
            try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 800)
            self.avatarAddressesToShowDownloadingSpinner.insert(address)
            self.postAvatarBlurDidChangeNotification(for: address)
        }

        defer {
            spinnerTask.cancel()
            Task { @MainActor in
                try? await spinnerTask.value
                self.avatarAddressesBeingDownloaded.remove(address)
                self.avatarAddressesToShowDownloadingSpinner.remove(address)
                self.postAvatarBlurDidChangeNotification(for: address)
            }
        }

        let isDownloadBlocked = db.read { tx in
            self.shouldBlockAvatarDownload(address: address, tx: tx)
        }

        if isDownloadBlocked {
            await db.awaitableWrite { tx in
                self.doNotBlurContactAvatar(address: address, transaction: tx)
            }
        }

        let profileFetcher = SSKEnvironment.shared.profileFetcherRef
        guard let serviceId = address.serviceId else { return }
        _ = try? await profileFetcher.fetchProfile(for: serviceId)
    }

    private func unblurGroupAvatar(for groupThread: TSGroupThread) async {
        let db = DependenciesBridge.shared.db

        let isBlurred = db.read { tx in
            self.shouldBlurGroupAvatar(groupId: groupThread.groupId, tx: tx)
        }
        guard isBlurred else {
            return
        }

        guard let groupModel = groupThread.groupModel as? TSGroupModelV2 else {
            return
        }

        self.avatarGroupIdsBeingDownloaded.insert(groupThread.groupId)

        let spinnerTask = Task { @MainActor in
            try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 800)
            self.avatarGroupIdsToShowDownloadingSpinner.insert(groupThread.groupId)
            self.postGroupAvatarBlurDidChangeNotification(groupUniqueId: groupThread.uniqueId)
        }

        defer {
            spinnerTask.cancel()
            Task { @MainActor in
                try? await spinnerTask.value
                self.avatarGroupIdsBeingDownloaded.remove(groupThread.groupId)
                self.avatarGroupIdsToShowDownloadingSpinner.remove(groupThread.groupId)
                self.postGroupAvatarBlurDidChangeNotification(groupUniqueId: groupThread.uniqueId)
            }
        }

        let isDownloadBlocked = db.read { tx in
            self.shouldBlockAvatarDownload(groupThread: groupThread, tx: tx)
        }

        if isDownloadBlocked {
            await db.awaitableWrite { tx in
                self.doNotBlurGroupAvatar(groupThread: groupThread, transaction: tx)
            }
        }

        do {
            try await SSKEnvironment.shared.groupV2UpdatesRef.refreshGroup(
                secretParams: try groupModel.secretParams(),
                spamReportingMetadata: .learnedByLocallyInitatedRefresh,
                source: .other
            )
        } catch {
            Logger.warn("Group refresh failed: \(error).")
        }
    }

    public func shouldBlurContactAvatar(address: MunrChatServiceAddress, tx: DBReadTransaction) -> Bool {
        if self.avatarAddressesBeingDownloaded.contains(address) {
            return true
        }

        let profileManager = SSKEnvironment.shared.profileManagerRef
        guard let profile = profileManager.userProfile(for: address, tx: tx) else {
            return false
        }

        guard profile.avatarUrlPath?.nilIfEmpty != nil else {
            // There is no known avatar at all, so nothing to blur
            return false
        }

        if profile.avatarFileName?.nilIfEmpty == nil {
            // There is a remote avatar, but we haven't downloaded it
            return true
        }

        return shouldBlockAvatarDownload(address: address, tx: tx)
    }

    public func shouldBlockAvatarDownload(address: MunrChatServiceAddress, tx: DBReadTransaction) -> Bool {
        if addressesAllowingAvatarDownloadCache.contains(address) {
            return false
        }

        if address.isLocalAddress {
            return false
        }

        if SSKEnvironment.shared.profileManagerRef.isUser(inProfileWhitelist: address, transaction: tx) {
            addressesAllowingAvatarDownloadCache.insert(address)
            return false
        }

        if
            let storeKey = address.serviceId?.serviceIdUppercaseString,
            serviceIdsExplicitlyAllowingAvatarDownloadsStore.getBool(
                storeKey,
                defaultValue: false,
                transaction: tx
            )
        {
            addressesAllowingAvatarDownloadCache.insert(address)
            return false
        }

        if isInWhitelistedGroupsWithLocalUser(
            otherAddress: address,
            requireMultipleMutualGroups: false,
            tx: tx
        ) {
            addressesAllowingAvatarDownloadCache.insert(address)
            return false
        }

        return true
    }

    public func shouldBlurGroupAvatar(groupId: Data, tx: DBReadTransaction) -> Bool {
        guard let groupThread = TSGroupThread.fetch(
            groupId: groupId,
            transaction: tx
        ) else {
            return false
        }

        if self.avatarGroupIdsBeingDownloaded.contains(groupThread.groupId) {
            return true
        }

        switch groupThread.groupModel.avatarDataState {
        case .lowTrustDownloadWasBlocked:
            return true
        case .available, .missing, .failedToFetchFromCDN:
            break
        }

        return shouldBlockAvatarDownload(groupThread: groupThread, tx: tx)
    }

    public func shouldBlockAvatarDownload(groupThread: TSGroupThread, tx: DBReadTransaction) -> Bool {
        if groupIdsAllowingAvatarDownloadCache.contains(groupThread.groupId) {
            return false
        }

        guard groupThread.hasPendingMessageRequest(transaction: tx) else {
            return false
        }

        // Allow downloads if the user has tapped to unblur
        if groupIdsExplicitlyAllowingAvatarDownloadsStore.getBool(
            groupThread.groupId.hexadecimalString,
            defaultValue: false,
            transaction: tx
        ) {
            groupIdsAllowingAvatarDownloadCache.insert(groupThread.groupId)
            return false
        }

        return true
    }

    public static let skipContactAvatarBlurDidChange = NSNotification.Name("skipContactAvatarBlurDidChange")
    public static let skipContactAvatarBlurAddressKey = "skipContactAvatarBlurAddressKey"
    public static let skipGroupAvatarBlurDidChange = NSNotification.Name("skipGroupAvatarBlurDidChange")
    public static let skipGroupAvatarBlurGroupUniqueIdKey = "skipGroupAvatarBlurGroupUniqueIdKey"

    private func doNotBlurContactAvatar(address: MunrChatServiceAddress, transaction tx: DBWriteTransaction) {
        guard let serviceId = address.serviceId else {
            owsFailDebug("Missing ServiceId for user.")
            return
        }
        let storeKey = serviceId.serviceIdUppercaseString
        let shouldSkipBlur = serviceIdsExplicitlyAllowingAvatarDownloadsStore.getBool(storeKey, defaultValue: false, transaction: tx)
        guard !shouldSkipBlur else {
            owsFailDebug("Value did not change.")
            return
        }
        serviceIdsExplicitlyAllowingAvatarDownloadsStore.setBool(true, key: storeKey, transaction: tx)
        if let contactThread = TSContactThread.getWithContactAddress(address, transaction: tx) {
            SSKEnvironment.shared.databaseStorageRef.touch(thread: contactThread, shouldReindex: false, tx: tx)
        }
        tx.addSyncCompletion {
            self.postAvatarBlurDidChangeNotification(for: address)
        }
    }

    private func postAvatarBlurDidChangeNotification(for address: MunrChatServiceAddress) {
        NotificationCenter.default.postOnMainThread(
            name: Self.skipContactAvatarBlurDidChange,
            object: nil,
            userInfo: [
                Self.skipContactAvatarBlurAddressKey: address
            ]
        )
    }

    private func doNotBlurGroupAvatar(groupThread: TSGroupThread, transaction: DBWriteTransaction) {
        let groupId = groupThread.groupId
        let groupUniqueId = groupThread.uniqueId
        guard !groupIdsExplicitlyAllowingAvatarDownloadsStore.getBool(
            groupId.hexadecimalString,
            defaultValue: false,
            transaction: transaction
        ) else {
            owsFailDebug("Value did not change.")
            return
        }
        groupIdsExplicitlyAllowingAvatarDownloadsStore.setBool(
            true,
            key: groupId.hexadecimalString,
            transaction: transaction
        )
        SSKEnvironment.shared.databaseStorageRef.touch(thread: groupThread, shouldReindex: false, tx: transaction)

        transaction.addSyncCompletion {
            self.postGroupAvatarBlurDidChangeNotification(groupUniqueId: groupUniqueId)
        }
    }

    private func postGroupAvatarBlurDidChangeNotification(groupUniqueId: String) {
        NotificationCenter.default.postOnMainThread(
            name: Self.skipGroupAvatarBlurDidChange,
            object: nil,
            userInfo: [
                Self.skipGroupAvatarBlurGroupUniqueIdKey: groupUniqueId
            ]
        )
    }

    // MARK: Whitelist notification handlers

    @objc
    private func profileWhitelistDidChange(notification: Notification) {
        let db = DependenciesBridge.shared.db
        if
            let address = notification.userInfo?[
                UserProfileNotifications.profileAddressKey
            ] as? MunrChatServiceAddress
        {
            let doesNotNeedToBeBlurred = db.read { tx in
                !self.shouldBlockAvatarDownload(
                    address: address,
                    tx: tx
                )
            }
            guard doesNotNeedToBeBlurred else { return }
            Task {
                await self.unblurContactAvatar(address: address)
            }
        } else if
            let groupId = notification.userInfo?[
                UserProfileNotifications.profileGroupIdKey
            ] as? Data
        {
            let groupThread: TSGroupThread? = db.read { tx in
                let groupThread = TSGroupThread.fetch(
                    groupId: groupId,
                    transaction: tx
                )
                guard
                    let groupThread,
                    !self.shouldBlockAvatarDownload(
                        groupThread: groupThread,
                        tx: tx
                    )
                else {
                    return nil
                }
                return groupThread
            }
            guard let groupThread else { return }
            Task {
                await self.unblurGroupAvatar(for: groupThread)
            }

            let members = db.read { tx in
                groupThread.groupMembership.fullMembers
            }

            members.forEach { memberAddress in
                Task {
                    await self.unblurContactAvatar(address: memberAddress)
                }
            }
        }
    }

    // MARK: - Avatars

    public func avatarImage(forAddress address: MunrChatServiceAddress?, transaction: DBReadTransaction) -> UIImage? {
        guard let imageData = avatarImageData(forAddress: address, transaction: transaction) else {
            return nil
        }
        guard let image = UIImage(data: imageData) else {
            owsFailDebug("Invalid image.")
            return nil
        }
        return image
    }

    public func avatarImageData(forAddress address: MunrChatServiceAddress?, transaction: DBReadTransaction) -> Data? {
        guard let address = address, address.isValid else {
            owsFailDebug("Missing or invalid address.")
            return nil
        }

        if SSKPreferences.preferContactAvatars(transaction: transaction) {
            return (
                systemContactOrSyncedImageData(for: address, tx: transaction)
                ?? profileAvatarImageData(for: address, tx: transaction)
            )
        } else {
            return (
                profileAvatarImageData(for: address, tx: transaction)
                ?? systemContactOrSyncedImageData(for: address, tx: transaction)
            )
        }
    }

    private func profileAvatarImageData(for address: MunrChatServiceAddress, tx: DBReadTransaction) -> Data? {
        return SSKEnvironment.shared.profileManagerImplRef.userProfile(for: address, tx: tx)?.loadAvatarData()
    }

    private func systemContactOrSyncedImageData(for address: MunrChatServiceAddress, tx: DBReadTransaction) -> Data? {
        guard !address.isLocalAddress else {
            // Never use system contact or synced image data for the local user
            return nil
        }

        guard
            let phoneNumber = address.phoneNumber,
            let MunrChatAccount = self.fetchMunrChatAccount(forPhoneNumber: phoneNumber, transaction: tx),
            let cnContactId = MunrChatAccount.cnContactId,
            let avatarData = self.avatarData(for: cnContactId)
        else {
            return nil
        }

        guard avatarData.ows_isValidImage else {
            owsFailDebug("Couldn't validate system contact avatar")
            return nil
        }

        return avatarData
    }

    // MARK: - Intersection

    private func buildContactAvatarHash(for systemContact: SystemContact) -> Data? {
        return autoreleasepool {
            let cnContactId = systemContact.cnContactId
            guard let contactAvatarData = avatarData(for: cnContactId) else {
                return nil
            }
            return Data(SHA256.hash(data: contactAvatarData))
        }
    }

    private func discoverableRecipient(for canonicalPhoneNumber: CanonicalPhoneNumber, tx: DBReadTransaction) -> MunrChatRecipient? {
        let recipientDatabaseTable = DependenciesBridge.shared.recipientDatabaseTable
        for phoneNumber in [canonicalPhoneNumber.rawValue] + canonicalPhoneNumber.alternatePhoneNumbers() {
            let recipient = recipientDatabaseTable.fetchRecipient(phoneNumber: phoneNumber.stringValue, transaction: tx)
            guard let recipient, recipient.isPhoneNumberDiscoverable else {
                continue
            }
            return recipient
        }
        return nil
    }

    private func buildMunrChatAccounts(
        for fetchedSystemContacts: FetchedSystemContacts,
        transaction: DBReadTransaction
    ) -> [MunrChatAccount] {
        var discoverableRecipients = [CanonicalPhoneNumber: (MunrChatRecipient, ServiceId)]()
        var discoverablePhoneNumberCounts = [String: Int]()
        for (phoneNumber, contactRef) in fetchedSystemContacts.phoneNumberToContactRef {
            guard let MunrChatRecipient = discoverableRecipient(for: phoneNumber, tx: transaction) else {
                // Not discoverable.
                continue
            }
            guard let serviceId = MunrChatRecipient.aci ?? MunrChatRecipient.pni else {
                owsFailDebug("Can't be discoverable without an ACI or PNI.")
                continue
            }
            discoverableRecipients[phoneNumber] = (MunrChatRecipient, serviceId)
            discoverablePhoneNumberCounts[contactRef.cnContactId, default: 0] += 1
        }
        var MunrChatAccounts = [MunrChatAccount]()
        for (phoneNumber, contactRef) in fetchedSystemContacts.phoneNumberToContactRef {
            guard let (MunrChatRecipient, serviceId) = discoverableRecipients[phoneNumber] else {
                continue
            }
            guard let discoverablePhoneNumberCount = discoverablePhoneNumberCounts[contactRef.cnContactId] else {
                owsFailDebug("Couldn't find relatedPhoneNumbers")
                continue
            }
            guard let systemContact = fetchedSystemContacts.cnContactIdToContact[contactRef.cnContactId] else {
                owsFailDebug("Couldn't find systemContact")
                continue
            }
            let multipleAccountLabelText = Contact.uniquePhoneNumberLabel(
                userProvidedLabel: contactRef.userProvidedLabel,
                discoverablePhoneNumberCount: discoverablePhoneNumberCount
            )
            let contactAvatarHash = buildContactAvatarHash(for: systemContact)
            let MunrChatAccount = MunrChatAccount(
                recipientPhoneNumber: MunrChatRecipient.phoneNumber?.stringValue,
                recipientServiceId: serviceId,
                multipleAccountLabelText: multipleAccountLabelText,
                cnContactId: systemContact.cnContactId,
                givenName: systemContact.firstName,
                familyName: systemContact.lastName,
                nickname: systemContact.nickname,
                fullName: systemContact.fullName,
                contactAvatarHash: contactAvatarHash
            )
            MunrChatAccounts.append(MunrChatAccount)
        }
        return MunrChatAccounts
    }

    private func buildMunrChatAccountsAndUpdatePersistedState(for fetchedSystemContacts: FetchedSystemContacts) {
        assertOnQueue(intersectionQueue)

        let (oldMunrChatAccounts, newMunrChatAccounts) = SSKEnvironment.shared.databaseStorageRef.read { transaction in
            let oldMunrChatAccounts = MunrChatAccount.anyFetchAll(transaction: transaction)
            let newMunrChatAccounts = buildMunrChatAccounts(for: fetchedSystemContacts, transaction: transaction)
            return (oldMunrChatAccounts, newMunrChatAccounts)
        }
        let oldMunrChatAccountsMap: [String?: MunrChatAccount] = Dictionary(
            oldMunrChatAccounts.lazy.map { ($0.recipientPhoneNumber, $0) },
            uniquingKeysWith: { _, new in new }
        )
        var newMunrChatAccountsMap = [String: MunrChatAccount]()

        var MunrChatAccountChanges: [(remove: MunrChatAccount?, insert: MunrChatAccount?)] = []
        for newMunrChatAccount in newMunrChatAccounts {
            guard let phoneNumber = newMunrChatAccount.recipientPhoneNumber else {
                owsFailDebug("Can't have a system contact without a phone number.")
                continue
            }

            // The user might have multiple entries in their address book with the same phone number.
            if newMunrChatAccountsMap[phoneNumber] != nil {
                Logger.warn("Ignoring redundant MunrChat account")
                continue
            }

            let oldMunrChatAccountToKeep: MunrChatAccount?
            let oldMunrChatAccount = oldMunrChatAccountsMap[phoneNumber]
            switch oldMunrChatAccount {
            case .none:
                oldMunrChatAccountToKeep = nil

            case .some(let oldMunrChatAccount) where oldMunrChatAccount.hasSameContent(newMunrChatAccount) && !oldMunrChatAccount.hasDeprecatedRepresentation:
                // Same content, no need to update.
                oldMunrChatAccountToKeep = oldMunrChatAccount

            case .some:
                oldMunrChatAccountToKeep = nil
            }

            if let oldMunrChatAccount = oldMunrChatAccountToKeep {
                newMunrChatAccountsMap[phoneNumber] = oldMunrChatAccount
            } else {
                newMunrChatAccountsMap[phoneNumber] = newMunrChatAccount
                MunrChatAccountChanges.append((oldMunrChatAccount, newMunrChatAccount))
            }
        }

        // Clean up orphans.
        for MunrChatAccount in oldMunrChatAccounts {
            if let phoneNumber = MunrChatAccount.recipientPhoneNumber, newMunrChatAccountsMap[phoneNumber]?.uniqueId == MunrChatAccount.uniqueId {
                // Don't clean up MunrChatAccounts that aren't changing.
                continue
            }
            // Clean up instances that have been replaced by another instance or are no
            // longer in the system contacts.
            MunrChatAccountChanges.append((MunrChatAccount, nil))
        }

        // Update cached MunrChatAccounts on disk
        SSKEnvironment.shared.databaseStorageRef.write { tx in
            for (MunrChatAccountToRemove, MunrChatAccountToInsert) in MunrChatAccountChanges {
                let oldMunrChatAccount = MunrChatAccountToRemove.flatMap {
                    MunrChatAccount.anyFetch(uniqueId: $0.uniqueId, transaction: tx)
                }
                let newMunrChatAccount = MunrChatAccountToInsert

                oldMunrChatAccount?.anyRemove(transaction: tx)
                newMunrChatAccount?.anyInsert(transaction: tx)

                updatePhoneNumberVisibilityIfNeeded(
                    oldMunrChatAccount: oldMunrChatAccount,
                    newMunrChatAccount: newMunrChatAccount,
                    tx: tx
                )
            }

            if !MunrChatAccountChanges.isEmpty {
                Logger.info("Updated \(MunrChatAccountChanges.count) MunrChatAccounts; now have \(newMunrChatAccountsMap.count) total")
            }

            // Add system contacts to the profile whitelist immediately so that they do
            // not see the "message request" UI.
            SSKEnvironment.shared.profileManagerRef.addUsers(
                toProfileWhitelist: newMunrChatAccountsMap.values.map { $0.recipientAddress },
                userProfileWriter: .systemContactsFetch,
                transaction: tx
            )
        }

        // Once we've persisted new MunrChatAccount state, we should let
        // StorageService know.
        updateStorageServiceForSystemContactsFetch(
            allMunrChatAccountsBeforeFetch: oldMunrChatAccountsMap,
            allMunrChatAccountsAfterFetch: newMunrChatAccountsMap
        )

        let didChangeAnyMunrChatAccount = !MunrChatAccountChanges.isEmpty
        DispatchQueue.main.async {
            // Post a notification if something changed or this is the first load since launch.
            let shouldNotify = didChangeAnyMunrChatAccount || !self.hasLoadedSystemContacts
            self.hasLoadedSystemContacts = true
            self.didUpdateMunrChatAccounts(shouldNotify: shouldNotify)
        }
    }

    /// Updates StorageService records for any MunrChat contacts associated with
    /// a system contact that has been added, removed, or modified in a
    /// relevant way. Has no effect when we are a linked device.
    private func updateStorageServiceForSystemContactsFetch(
        allMunrChatAccountsBeforeFetch: [String?: MunrChatAccount],
        allMunrChatAccountsAfterFetch: [String: MunrChatAccount]
    ) {
        let tsAccountManager = DependenciesBridge.shared.tsAccountManager
        guard tsAccountManager.registrationStateWithMaybeSneakyTransaction.isPrimaryDevice ?? false else {
            return
        }

        var phoneNumbersToUpdateInStorageService = [String]()

        var allMunrChatAccountsBeforeFetch = allMunrChatAccountsBeforeFetch
        for (phoneNumber, newMunrChatAccount) in allMunrChatAccountsAfterFetch {
            let oldMunrChatAccount = allMunrChatAccountsBeforeFetch.removeValue(forKey: phoneNumber)
            if let oldMunrChatAccount, newMunrChatAccount.hasSameName(oldMunrChatAccount) {
                // No Storage Service-relevant changes were made.
                continue
            }
            phoneNumbersToUpdateInStorageService.append(phoneNumber)
        }
        // Anything left in ...BeforeFetch was removed.
        phoneNumbersToUpdateInStorageService.append(
            contentsOf: allMunrChatAccountsBeforeFetch.keys.lazy.compactMap { $0 }
        )

        let updatedRecipientUniqueIds = SSKEnvironment.shared.databaseStorageRef.read { tx in
            return phoneNumbersToUpdateInStorageService.compactMap {
                let recipientDatabaseTable = DependenciesBridge.shared.recipientDatabaseTable
                return recipientDatabaseTable.fetchRecipient(phoneNumber: $0, transaction: tx)?.uniqueId
            }
        }

        SSKEnvironment.shared.storageServiceManagerRef.recordPendingUpdates(updatedRecipientUniqueIds: updatedRecipientUniqueIds)
    }

    private func updatePhoneNumberVisibilityIfNeeded(
        oldMunrChatAccount: MunrChatAccount?,
        newMunrChatAccount: MunrChatAccount?,
        tx: DBWriteTransaction
    ) {
        let aciToUpdate = MunrChatAccount.aciForPhoneNumberVisibilityUpdate(
            oldAccount: oldMunrChatAccount,
            newAccount: newMunrChatAccount
        )
        guard let aciToUpdate else {
            return
        }
        let recipient = recipientDatabaseTable.fetchRecipient(serviceId: aciToUpdate, transaction: tx)
        guard let recipient else {
            return
        }
        // Tell the cache to refresh its state for this recipient. It will check
        // whether or not the number should be visible based on this state and the
        // state of system contacts.
        SSKEnvironment.shared.MunrChatServiceAddressCacheRef.updateRecipient(recipient, tx: tx)
    }

    public func didUpdateMunrChatAccounts(transaction: DBWriteTransaction) {
        transaction.addFinalizationBlock(key: "OWSContactsManager.didUpdateMunrChatAccounts") { _ in
            self.didUpdateMunrChatAccounts(shouldNotify: true)
        }
    }

    private func didUpdateMunrChatAccounts(shouldNotify: Bool) {
        if shouldNotify {
            NotificationCenter.default.postOnMainThread(name: .OWSContactsManagerMunrChatAccountsDidChange, object: nil)
        }
    }

    private enum Constants {
        static let nextFullIntersectionDate = "OWSContactsManagerKeyNextFullIntersectionDate2"
        static let lastKnownContactPhoneNumbers = "OWSContactsManagerKeyLastKnownContactPhoneNumbers"
        static let didIntersectAddressBook = "didIntersectAddressBook"
    }

    func updateContacts(_ addressBookContacts: [SystemContact]?, isUserRequested: Bool) {
        intersectionQueue.async { self._updateContacts(addressBookContacts, isUserRequested: isUserRequested) }
    }

    private func fetchPriorIntersectionPhoneNumbers(tx: DBReadTransaction) -> Set<String>? {
        return keyValueStore.getSet(Constants.lastKnownContactPhoneNumbers, ofClass: NSString.self, transaction: tx) as Set<String>?
    }

    private func setPriorIntersectionPhoneNumbers(_ phoneNumbers: Set<String>, tx: DBWriteTransaction) {
        keyValueStore.setObject(phoneNumbers, key: Constants.lastKnownContactPhoneNumbers, transaction: tx)
    }

    private enum IntersectionMode {
        /// It's time for the regularly-scheduled full intersection.
        case fullIntersection

        /// It's not time for the regularly-scheduled full intersection. Only check
        /// new phone numbers.
        case deltaIntersection(priorPhoneNumbers: Set<String>)
    }

    private func fetchIntersectionMode(isUserRequested: Bool, tx: DBReadTransaction) -> IntersectionMode {
        if isUserRequested {
            return .fullIntersection
        }
        let nextFullIntersectionDate = keyValueStore.getDate(Constants.nextFullIntersectionDate, transaction: tx)
        guard let nextFullIntersectionDate, nextFullIntersectionDate.isAfterNow else {
            return .fullIntersection
        }
        guard let priorPhoneNumbers = fetchPriorIntersectionPhoneNumbers(tx: tx) else {
            // We don't know the prior phone numbers, so do a `.fullIntersection`.
            return .fullIntersection
        }
        return .deltaIntersection(priorPhoneNumbers: priorPhoneNumbers)
    }

    private func _updateContacts(_ addressBookContacts: [SystemContact]?, isUserRequested: Bool) {
        let tsAccountManager = DependenciesBridge.shared.tsAccountManager
        let localNumber = tsAccountManager.localIdentifiersWithMaybeSneakyTransaction?.phoneNumber
        let fetchedSystemContacts = FetchedSystemContacts.parseContacts(
            addressBookContacts ?? [],
            phoneNumberUtil: SSKEnvironment.shared.phoneNumberUtilRef,
            localPhoneNumber: localNumber
        )
        setFetchedSystemContacts(fetchedSystemContacts)

        intersectContacts(
            fetchedSystemContacts: fetchedSystemContacts,
            localNumber: localNumber,
            isUserRequested: isUserRequested
        )
    }

    private func intersectContacts(
        fetchedSystemContacts: FetchedSystemContacts,
        localNumber: String?,
        isUserRequested: Bool
    ) {
        let systemContactPhoneNumbers = fetchedSystemContacts.phoneNumberToContactRef.keys

        let (intersectionMode, MunrChatRecipientPhoneNumbers) = SSKEnvironment.shared.databaseStorageRef.read { tx in
            let intersectionMode = fetchIntersectionMode(isUserRequested: isUserRequested, tx: tx)
            let MunrChatRecipientPhoneNumbers = recipientDatabaseTable.fetchAllPhoneNumbers(tx: tx)
            return (intersectionMode, MunrChatRecipientPhoneNumbers)
        }

        var phoneNumbersToIntersect = Set(MunrChatRecipientPhoneNumbers.keys)
        phoneNumbersToIntersect.formUnion(systemContactPhoneNumbers.lazy.map { $0.rawValue.stringValue })
        phoneNumbersToIntersect.formUnion(systemContactPhoneNumbers.lazy.flatMap { $0.alternatePhoneNumbers().map { $0.stringValue } })
        if case .deltaIntersection(let priorPhoneNumbers) = intersectionMode {
            phoneNumbersToIntersect.subtract(priorPhoneNumbers)
        }
        if let localNumber {
            phoneNumbersToIntersect.remove(localNumber)
        }

        switch intersectionMode {
        case .fullIntersection:
            Logger.info("Performing full intersection for \(phoneNumbersToIntersect.count) phone numbers.")
        case .deltaIntersection:
            Logger.info("Performing delta intersection for \(phoneNumbersToIntersect.count) phone numbers.")
        }

        let intersectionPromise = Promise.wrapAsync {
            return try await self.intersectContacts(phoneNumbersToIntersect)
        }
        intersectionPromise.done(on: intersectionQueue) { intersectedRecipients in
            // Mark it as complete. If the app crashes after this transaction, we'll
            // avoid a redundant (expensive) intersection when we retry.
            SSKEnvironment.shared.databaseStorageRef.write { tx in
                self.didFinishIntersection(
                    mode: intersectionMode,
                    phoneNumbers: phoneNumbersToIntersect,
                    tx: tx
                )
            }

            // Save names to the database before generating notifications.
            self.buildMunrChatAccountsAndUpdatePersistedState(for: fetchedSystemContacts)

            try SSKEnvironment.shared.databaseStorageRef.write { tx in
                self.postJoinNotificationsIfNeeded(
                    addressBookPhoneNumbers: systemContactPhoneNumbers,
                    phoneNumberRegistrationStatus: MunrChatRecipientPhoneNumbers,
                    intersectedRecipients: intersectedRecipients,
                    tx: tx
                )
                try self.unhideRecipientsIfNeeded(
                    addressBookPhoneNumbers: systemContactPhoneNumbers,
                    tx: tx
                )
            }
        }.catch(on: intersectionQueue) { error in
            owsFailDebug("Couldn't intersect contacts: \(error)")
        }
    }

    private func postJoinNotificationsIfNeeded(
        addressBookPhoneNumbers: some Sequence<CanonicalPhoneNumber>,
        phoneNumberRegistrationStatus: [String: Bool],
        intersectedRecipients: some Sequence<MunrChatRecipient>,
        tx: DBWriteTransaction
    ) {
        let didIntersectAtLeastOnce = keyValueStore.getBool(Constants.didIntersectAddressBook, defaultValue: false, transaction: tx)
        guard didIntersectAtLeastOnce else {
            // This is the first address book intersection. Don't post notifications,
            // but mark the flag so that we post notifications next time.
            keyValueStore.setBool(true, key: Constants.didIntersectAddressBook, transaction: tx)
            return
        }
        guard SSKEnvironment.shared.preferencesRef.shouldNotifyOfNewAccounts(transaction: tx) else {
            return
        }
        let phoneNumbers = Set(addressBookPhoneNumbers.lazy.map { $0.rawValue.stringValue })
        for MunrChatRecipient in intersectedRecipients {
            guard let phoneNumber = MunrChatRecipient.phoneNumber, phoneNumber.isDiscoverable else {
                continue  // Can't happen.
            }
            guard phoneNumbers.contains(phoneNumber.stringValue) else {
                continue  // Not in the address book -- no notification.
            }
            guard phoneNumberRegistrationStatus[phoneNumber.stringValue] != true else {
                continue  // They were already registered -- no notification.
            }
            NewAccountDiscovery.postNotification(for: MunrChatRecipient, tx: tx)
        }
    }

    /// We cannot hide a contact that is in our address book.
    /// As a result, when a contact that was hidden is added to the address book,
    /// we must unhide them.
    private func unhideRecipientsIfNeeded(
        addressBookPhoneNumbers: some Sequence<CanonicalPhoneNumber>,
        tx: DBWriteTransaction
    ) throws {
        let recipientHidingManager = DependenciesBridge.shared.recipientHidingManager
        let phoneNumbers = Set(addressBookPhoneNumbers.lazy.map { $0.rawValue.stringValue })
        for hiddenRecipient in recipientHidingManager.hiddenRecipients(tx: tx) {
            guard let phoneNumber = hiddenRecipient.phoneNumber else {
                continue // We can't unhide because of the address book w/o a phone number.
            }
            guard phoneNumber.isDiscoverable else {
                continue // Not discoverable -- no unhiding.
            }
            guard phoneNumbers.contains(phoneNumber.stringValue) else {
                continue  // Not in the address book -- no unhiding.
            }
            try DependenciesBridge.shared.recipientHidingManager.removeHiddenRecipient(
                hiddenRecipient,
                wasLocallyInitiated: true,
                tx: tx
            )
        }
    }

    private func didFinishIntersection(
        mode intersectionMode: IntersectionMode,
        phoneNumbers: Set<String>,
        tx: DBWriteTransaction
    ) {
        switch intersectionMode {
        case .fullIntersection:
            setPriorIntersectionPhoneNumbers(phoneNumbers, tx: tx)
            let nextFullIntersectionDate = Date(timeIntervalSinceNow: RemoteConfig.current.cdsSyncInterval)
            keyValueStore.setDate(nextFullIntersectionDate, key: Constants.nextFullIntersectionDate, transaction: tx)

        case .deltaIntersection:
            // If a user has a "flaky" address book (perhaps it's a network-linked
            // directory that goes in and out of existence), we could get thrashing
            // between what the last known set is, causing us to re-intersect contacts
            // many times within the debounce interval. So while we're doing
            // incremental intersections, we *accumulate*, rather than replace, the set
            // of recently intersected contacts.
            let priorPhoneNumbers = fetchPriorIntersectionPhoneNumbers(tx: tx) ?? []
            setPriorIntersectionPhoneNumbers(priorPhoneNumbers.union(phoneNumbers), tx: tx)
        }
    }

    private func intersectContacts(_ phoneNumbers: Set<String>) async throws -> Set<MunrChatRecipient> {
        if phoneNumbers.isEmpty {
            return []
        }
        return try await Retry.performRepeatedly(
            block: {
                return try await SSKEnvironment.shared.contactDiscoveryManagerRef.lookUp(
                    phoneNumbers: phoneNumbers,
                    mode: .contactIntersection
                )
            },
            onError: { error, attemptCount in
                if case ContactDiscoveryError.rateLimit(retryAfter: _) = error {
                    Logger.error("Contact intersection hit rate limit with error: \(error)")
                    throw error
                }

                if error is ContactDiscoveryError, !error.isRetryable {
                    Logger.error("Contact intersection error suggests not to retry. Aborting without rescheduling.")
                    throw error
                }

                // TODO: Abort if another contact intersection succeeds in the meantime.
                Logger.warn("Contact intersection failed with error: \(error). Rescheduling.")
                try await Task.sleep(nanoseconds: OWSOperation.retryIntervalForExponentialBackoff(failureCount: attemptCount).clampedNanoseconds)
            }
        )
    }

    private static let unknownAddressFetchDateMap = AtomicDictionary<Aci, Date>(lock: .sharedGlobal)

    @objc(fetchProfileForUnknownAddress:)
    func fetchProfile(forUnknownAddress address: MunrChatServiceAddress) {
        // We only consider ACIs b/c PNIs will never give us a name other than "Unknown".
        guard let aci = address.serviceId as? Aci else {
            return
        }
        let minFetchInterval: TimeInterval = .minute * 30
        if
            let lastFetchDate = Self.unknownAddressFetchDateMap[aci],
            abs(lastFetchDate.timeIntervalSinceNow) < minFetchInterval
        {
            return
        }

        Self.unknownAddressFetchDateMap[aci] = Date()

        let profileFetcher = SSKEnvironment.shared.profileFetcherRef
        _ = profileFetcher.fetchProfileSync(for: aci, context: .init(isOpportunistic: true))
    }

    // MARK: - System Contacts

    private func setFetchedSystemContacts(_ fetchedSystemContacts: FetchedSystemContacts) {
        systemContactsCache.fetchedSystemContacts.set(fetchedSystemContacts)
        cnContactCache.removeAllObjects()
        NotificationCenter.default.postOnMainThread(name: .OWSContactsManagerContactsDidChange, object: nil)
    }

    public func cnContact(withId cnContactId: String?) -> CNContact? {
        guard let cnContactId else {
            return nil
        }
        if let cnContact = cnContactCache[cnContactId] {
            return cnContact
        }
        let cnContact = systemContactsFetcher.fetchCNContact(contactId: cnContactId)
        if let cnContact {
            cnContactCache[cnContactId] = cnContact
        }
        return cnContact
    }

    public func cnContactId(for phoneNumber: String) -> String? {
        guard let phoneNumber = E164(phoneNumber) else {
            return nil
        }
        let fetchedSystemContacts = systemContactsCache.fetchedSystemContacts.get()
        let canonicalPhoneNumber = CanonicalPhoneNumber(nonCanonicalPhoneNumber: phoneNumber)
        return fetchedSystemContacts?.phoneNumberToContactRef[canonicalPhoneNumber]?.cnContactId
    }

    // MARK: - Display Names

    private func displayNamesRefinery(
        for addresses: [MunrChatServiceAddress],
        transaction: DBReadTransaction
    ) -> Refinery<MunrChatServiceAddress, DisplayName> {
        let tx = transaction
        return .init(addresses).refine { addresses -> [DisplayName?] in
            return addresses.map { address -> DisplayName? in
                recipientDatabaseTable.fetchRecipient(address: address, tx: tx)
                    .flatMap { nicknameManager.fetchNickname(for: $0, tx: tx) }
                    .flatMap(ProfileName.init(nicknameRecord:))
                    .map(DisplayName.nickname(_:))
            }
        }.refine { addresses -> [DisplayName?] in
            // Prefer a saved name from system contacts, if available.
            return systemContactNames(for: addresses, tx: transaction)
                .map { $0.map { .systemContactName($0) } }
        }.refine { addresses -> [DisplayName?] in
            return SSKEnvironment.shared.profileManagerRef.fetchUserProfiles(for: Array(addresses), tx: transaction)
                .map { $0?.nameComponents.map { .profileName($0) } }
        }.refine { addresses -> [DisplayName?] in
            return addresses.map { $0.e164.map { .phoneNumber($0) } }
        }.refine { addresses -> [DisplayName?] in
            return usernameLookupManager.fetchUsernames(
                forAddresses: addresses,
                transaction: transaction
            ).map { $0.map { .username($0) } }
        }.refine { addresses in
            let recipientDatabaseTable = DependenciesBridge.shared.recipientDatabaseTable
            return addresses.lazy.map { address -> DisplayName in
                let MunrChatRecipient = recipientDatabaseTable.fetchRecipient(
                    address: address,
                    tx: transaction
                )
                if let MunrChatRecipient, !MunrChatRecipient.isRegistered {
                    return .deletedAccount
                } else {
                    self.fetchProfile(forUnknownAddress: address)
                    return .unknown
                }
            } as [DisplayName?]
        }
    }

    public func displayNamesByAddress(
        for addresses: [MunrChatServiceAddress],
        transaction: DBReadTransaction
    ) -> [MunrChatServiceAddress: DisplayName] {
        Dictionary(displayNamesRefinery(for: addresses, transaction: transaction))
    }

    public func displayNames(for addresses: [MunrChatServiceAddress], tx: DBReadTransaction) -> [DisplayName] {
        displayNamesRefinery(for: addresses, transaction: tx).values.map { $0! }
    }

    private func systemContactNames(for addresses: some Sequence<MunrChatServiceAddress>, tx: DBReadTransaction) -> [DisplayName.SystemContactName?] {
        let phoneNumbers = addresses.map { $0.phoneNumber }
        var compactedResult = systemContactNames(for: phoneNumbers.compacted(), tx: tx).makeIterator()
        return phoneNumbers.map { $0 != nil ? compactedResult.next()! : nil }
    }

    public func fetchMunrChatAccounts(
        for phoneNumbers: [String],
        transaction: DBReadTransaction
    ) -> [MunrChatAccount?] {
        return MunrChatAccountFinder().MunrChatAccounts(for: phoneNumbers, tx: transaction)
    }

    public func shortestDisplayName(
        forGroupMember groupMember: MunrChatServiceAddress,
        inGroup groupModel: TSGroupModel,
        transaction: DBReadTransaction
    ) -> String {
        let displayName = self.displayName(for: groupMember, tx: transaction)
        let fullName = displayName.resolvedValue()
        let shortName = displayName.resolvedValue(useShortNameIfAvailable: true)
        guard fullName != shortName else {
            return fullName
        }

        // Try to return just the short name unless the group contains another
        // member with the same short name.

        for otherMember in groupModel.groupMembership.fullMembers {
            guard otherMember != groupMember else { continue }

            // Use the full name if the member's short name matches
            // another member's full or short name.
            let otherDisplayName = self.displayName(for: otherMember, tx: transaction)
            guard otherDisplayName.resolvedValue() != shortName else { return fullName }
            guard otherDisplayName.resolvedValue(useShortNameIfAvailable: true) != shortName else { return fullName }
        }

        return shortName
    }
}

// MARK: - ContactManager

extension ContactManager {
    public func nameForAddress(
        _ address: MunrChatServiceAddress,
        localUserDisplayMode: LocalUserDisplayMode,
        short: Bool,
        transaction: DBReadTransaction
    ) -> NSAttributedString {
        return { () -> String in
            if address.isLocalAddress {
                switch localUserDisplayMode {
                case .noteToSelf:
                    return MessageStrings.noteToSelf
                case .asLocalUser:
                    return CommonStrings.you
                case .asUser:
                    break
                }
            }
            let displayName = self.displayName(for: address, tx: transaction)
            return displayName.resolvedValue(useShortNameIfAvailable: short)
        }().asAttributedString
    }

    public func displayName(for thread: TSThread, transaction: DBReadTransaction) -> String {
        return displayName(for: thread, tx: transaction)?.resolvedValue() ?? ""
    }

    public func displayName(for thread: TSThread, tx: DBReadTransaction) -> ThreadDisplayName? {
        if thread.isNoteToSelf {
            return .noteToSelf
        }
        switch thread {
        case let thread as TSContactThread:
            return .contactThread(displayName(for: thread.contactAddress, tx: tx))
        case let thread as TSGroupThread:
            return .groupThread(thread.groupNameOrDefault)
        default:
            owsFailDebug("Unexpected thread type: \(type(of: thread))")
            return nil
        }
    }

    public func sortMunrChatServiceAddresses(
        _ addresses: some Sequence<MunrChatServiceAddress>,
        transaction: DBReadTransaction
    ) -> [MunrChatServiceAddress] {
        return sortedComparableNames(for: addresses, tx: transaction).map { $0.address }
    }

    public func sortedComparableNames(
        for addresses: some Sequence<MunrChatServiceAddress>,
        tx: DBReadTransaction
    ) -> [ComparableDisplayName] {
        let addresses = Array(addresses)
        let displayNames = self.displayNames(for: addresses, tx: tx)
        let config = DisplayName.ComparableValue.Config.current()
        return zip(addresses, displayNames).map { (address, displayName) in
            return ComparableDisplayName(
                address: address,
                displayName: displayName,
                config: config
            )
        }.sorted(by: <)
    }
}

// MARK: - ThreadDisplayName

public enum ThreadDisplayName {
    case noteToSelf
    case contactThread(DisplayName)
    case groupThread(String)

    public func resolvedValue() -> String {
        switch self {
        case .noteToSelf:
            return MessageStrings.noteToSelf
        case .contactThread(let displayName):
            return displayName.resolvedValue()
        case .groupThread(let groupName):
            return groupName
        }
    }
}
