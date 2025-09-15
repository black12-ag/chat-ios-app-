//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Contacts
import Foundation
import LibMunrChatClient

enum ContactSyncAttachmentBuilder {
    static func buildAttachmentFile(
        contactsManager: OWSContactsManager,
        tx: DBReadTransaction
    ) -> URL? {
        let tsAccountManager = DependenciesBridge.shared.tsAccountManager
        guard let localAddress = tsAccountManager.localIdentifiers(tx: tx)?.aciAddress else {
            owsFailDebug("Missing localAddress.")
            return nil
        }

        let fileUrl = OWSFileSystem.temporaryFileUrl(isAvailableWhileDeviceLocked: true)
        guard let outputStream = OutputStream(url: fileUrl, append: false) else {
            owsFailDebug("Could not open outputStream.")
            return nil
        }
        let outputStreamDelegate = OWSStreamDelegate()
        outputStream.delegate = outputStreamDelegate
        outputStream.schedule(in: .current, forMode: .default)
        outputStream.open()
        guard outputStream.streamStatus == .open else {
            owsFailDebug("Could not open outputStream.")
            return nil
        }

        do {
            defer {
                outputStream.remove(from: .current, forMode: .default)
                outputStream.close()
            }
            try fetchAndWriteContacts(
                to: ContactOutputStream(outputStream: outputStream),
                localAddress: localAddress,
                contactsManager: contactsManager,
                tx: tx
            )
        } catch {
            owsFailDebug("Could not write contacts sync stream: \(error)")
            return nil
        }

        guard outputStream.streamStatus == .closed, !outputStreamDelegate.hadError else {
            owsFailDebug("Could not close stream.")
            return nil
        }

        return fileUrl
    }

    private static func fetchAndWriteContacts(
        to contactOutputStream: ContactOutputStream,
        localAddress: MunrChatServiceAddress,
        contactsManager: OWSContactsManager,
        tx: DBReadTransaction
    ) throws {
        let threadFinder = ThreadFinder()
        var threadPositions = [Int64: Int]()
        for (inboxPosition, rowId) in try threadFinder.fetchContactSyncThreadRowIds(tx: tx).enumerated() {
            threadPositions[rowId] = inboxPosition + 1 // Row numbers start from 1.
        }

        let localAccount = localAccountToSync(localAddress: localAddress)
        let otherAccounts = MunrChatAccount.anyFetchAll(transaction: tx)
        let MunrChatAccounts = [localAccount] + otherAccounts.sorted(
            by: { ($0.recipientPhoneNumber ?? "") < ($1.recipientPhoneNumber ?? "") }
        )

        let recipientDatabaseTable = DependenciesBridge.shared.recipientDatabaseTable

        for MunrChatAccount in MunrChatAccounts {
            try autoreleasepool {
                guard let phoneNumber = MunrChatAccount.recipientPhoneNumber else {
                    return
                }
                let MunrChatRecipient = recipientDatabaseTable.fetchRecipient(phoneNumber: phoneNumber, transaction: tx)
                guard let MunrChatRecipient else {
                    return
                }
                let contactThread = TSContactThread.getWithContactAddress(MunrChatRecipient.address, transaction: tx)
                let inboxPosition = contactThread?.sqliteRowId.flatMap { threadPositions.removeValue(forKey: $0) }
                try writeContact(
                    to: contactOutputStream,
                    address: MunrChatRecipient.address,
                    contactThread: contactThread,
                    MunrChatAccount: MunrChatAccount,
                    inboxPosition: inboxPosition,
                    tx: tx
                )
            }
        }

        for (rowId, inboxPosition) in threadPositions.sorted(by: { $0.key < $1.key }) {
            try autoreleasepool {
                guard let contactThread = threadFinder.fetch(rowId: rowId, tx: tx) as? TSContactThread else {
                    return
                }
                try writeContact(
                    to: contactOutputStream,
                    address: contactThread.contactAddress,
                    contactThread: contactThread,
                    MunrChatAccount: nil,
                    inboxPosition: inboxPosition,
                    tx: tx
                )
            }
        }
    }

    private static func writeContact(
        to contactOutputStream: ContactOutputStream,
        address: MunrChatServiceAddress,
        contactThread: TSContactThread?,
        MunrChatAccount: MunrChatAccount?,
        inboxPosition: Int?,
        tx: DBReadTransaction
    ) throws {
        let dmStore = DependenciesBridge.shared.disappearingMessagesConfigurationStore
        let dmConfiguration = contactThread.map { dmStore.fetchOrBuildDefault(for: .thread($0), tx: tx) }

        try contactOutputStream.writeContact(
            aci: address.serviceId as? Aci,
            phoneNumber: address.e164,
            MunrChatAccount: MunrChatAccount,
            disappearingMessagesConfiguration: dmConfiguration,
            inboxPosition: inboxPosition
        )
    }

    private static func localAccountToSync(localAddress: MunrChatServiceAddress) -> MunrChatAccount {
        // OWSContactsOutputStream requires all MunrChatAccount to have a contact.
        return MunrChatAccount(
            recipientPhoneNumber: localAddress.phoneNumber,
            recipientServiceId: localAddress.serviceId,
            multipleAccountLabelText: nil,
            cnContactId: nil,
            givenName: "",
            familyName: "",
            nickname: "",
            fullName: "",
            contactAvatarHash: nil,
        )
    }
}

private class OWSStreamDelegate: NSObject, StreamDelegate {
    private let _hadError = AtomicBool(false, lock: .sharedGlobal)
    public var hadError: Bool { _hadError.get() }

    @objc
    public func stream(_ stream: Stream, handle eventCode: Stream.Event) {
        if eventCode == .errorOccurred {
            _hadError.set(true)
        }
    }
}
