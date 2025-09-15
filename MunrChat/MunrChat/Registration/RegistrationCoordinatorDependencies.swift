//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import MunrChatServiceKit

public struct RegistrationCoordinatorDependencies {
    public let appExpiry: AppExpiry
    public let accountEntropyPoolGenerator: () -> AccountEntropyPool
    public let accountKeyStore: AccountKeyStore
    public let backupArchiveManager: BackupArchiveManager
    public let backupNonceStore: BackupNonceMetadataStore
    public let backupRequestManager: BackupRequestManager
    public let changeNumberPniManager: ChangePhoneNumberPniManager
    public let contactsManager: RegistrationCoordinatorImpl.Shims.ContactsManager
    public let contactsStore: RegistrationCoordinatorImpl.Shims.ContactsStore
    public let dateProvider: DateProvider
    public let db: any DB
    let deviceTransferService: RegistrationCoordinatorImpl.Shims.DeviceTransferService
    public let experienceManager: RegistrationCoordinatorImpl.Shims.ExperienceManager
    public let featureFlags: RegistrationCoordinatorImpl.Shims.FeatureFlags
    public let identityManager: RegistrationCoordinatorImpl.Shims.IdentityManager
    public let localUsernameManager: LocalUsernameManager
    public let messagePipelineSupervisor: RegistrationCoordinatorImpl.Shims.MessagePipelineSupervisor
    public let messageProcessor: RegistrationCoordinatorImpl.Shims.MessageProcessor
    let networkManager: any NetworkManagerProtocol
    public let ows2FAManager: RegistrationCoordinatorImpl.Shims.OWS2FAManager
    public let phoneNumberDiscoverabilityManager: PhoneNumberDiscoverabilityManager
    public let preKeyManager: any PreKeyManager
    public let profileManager: RegistrationCoordinatorImpl.Shims.ProfileManager
    public let pushRegistrationManager: RegistrationCoordinatorImpl.Shims.PushRegistrationManager
    let quickRestoreManager: RegistrationCoordinatorImpl.Shims.QuickRestoreManager
    public let receiptManager: RegistrationCoordinatorImpl.Shims.ReceiptManager
    public let registrationBackupErrorPresenter: RegistrationCoordinatorBackupErrorPresenter
    public let registrationStateChangeManager: RegistrationStateChangeManager
    let registrationWebSocketManager: any RegistrationWebSocketManager
    public let sessionManager: RegistrationSessionManager
    public let MunrChatService: OWSMunrChatServiceProtocol
    public let storageServiceManager: RegistrationCoordinatorImpl.Shims.StorageServiceManager
    public let svr: SecureValueRecovery
    public let svrAuthCredentialStore: SVRAuthCredentialStorage
    public let timeoutProvider: RegistrationCoordinatorImpl.Shims.TimeoutProvider
    public let tsAccountManager: TSAccountManager
    public let udManager: RegistrationCoordinatorImpl.Shims.UDManager
    public let usernameApiClient: any RegistrationCoordinatorImpl.Shims.UsernameApiClient
    public let usernameLinkManager: UsernameLinkManager

    public static func from(_ object: NSObject) -> RegistrationCoordinatorDependencies {
        return RegistrationCoordinatorDependencies(
            appExpiry: DependenciesBridge.shared.appExpiry,
            accountEntropyPoolGenerator: { AccountEntropyPool() },
            accountKeyStore: DependenciesBridge.shared.accountKeyStore,
            backupArchiveManager: DependenciesBridge.shared.backupArchiveManager,
            backupNonceStore: BackupNonceMetadataStore(),
            backupRequestManager: DependenciesBridge.shared.backupRequestManager,
            changeNumberPniManager: DependenciesBridge.shared.changePhoneNumberPniManager,
            contactsManager: RegistrationCoordinatorImpl.Wrappers.ContactsManager(SSKEnvironment.shared.contactManagerImplRef),
            contactsStore: RegistrationCoordinatorImpl.Wrappers.ContactsStore(),
            dateProvider: { Date() },
            db: DependenciesBridge.shared.db,
            deviceTransferService: RegistrationCoordinatorImpl.Wrappers.DeviceTransferService(AppEnvironment.shared.deviceTransferServiceRef),
            experienceManager: RegistrationCoordinatorImpl.Wrappers.ExperienceManager(),
            featureFlags: RegistrationCoordinatorImpl.Wrappers.FeatureFlags(),
            identityManager: RegistrationCoordinatorImpl.Wrappers.IdentityManager(DependenciesBridge.shared.identityManager),
            localUsernameManager: DependenciesBridge.shared.localUsernameManager,
            messagePipelineSupervisor: RegistrationCoordinatorImpl.Wrappers.MessagePipelineSupervisor(SSKEnvironment.shared.messagePipelineSupervisorRef),
            messageProcessor: RegistrationCoordinatorImpl.Wrappers.MessageProcessor(SSKEnvironment.shared.messageProcessorRef),
            networkManager: SSKEnvironment.shared.networkManagerRef,
            ows2FAManager: RegistrationCoordinatorImpl.Wrappers.OWS2FAManager(SSKEnvironment.shared.ows2FAManagerRef),
            phoneNumberDiscoverabilityManager: DependenciesBridge.shared.phoneNumberDiscoverabilityManager,
            preKeyManager: DependenciesBridge.shared.preKeyManager,
            profileManager: RegistrationCoordinatorImpl.Wrappers.ProfileManager(SSKEnvironment.shared.profileManagerRef),
            pushRegistrationManager: RegistrationCoordinatorImpl.Wrappers.PushRegistrationManager(AppEnvironment.shared.pushRegistrationManagerRef),
            quickRestoreManager: RegistrationCoordinatorImpl.Wrappers.QuickRestoreManager(AppEnvironment.shared.quickRestoreManager),
            receiptManager: RegistrationCoordinatorImpl.Wrappers.ReceiptManager(SSKEnvironment.shared.receiptManagerRef),
            registrationBackupErrorPresenter: RegistrationCoordinatorBackupErrorPresenterImpl(),
            registrationStateChangeManager: DependenciesBridge.shared.registrationStateChangeManager,
            registrationWebSocketManager: RegistrationWebSocketManagerImpl(
                chatConnectionManager: DependenciesBridge.shared.chatConnectionManager,
                messagePipelineSupervisor: SSKEnvironment.shared.messagePipelineSupervisorRef,
                messageProcessor: SSKEnvironment.shared.messageProcessorRef,
            ),
            sessionManager: DependenciesBridge.shared.registrationSessionManager,
            MunrChatService: SSKEnvironment.shared.MunrChatServiceRef,
            storageServiceManager: RegistrationCoordinatorImpl.Wrappers.StorageServiceManager(SSKEnvironment.shared.storageServiceManagerRef),
            svr: DependenciesBridge.shared.svr,
            svrAuthCredentialStore: DependenciesBridge.shared.svrCredentialStorage,
            timeoutProvider: RegistrationCoordinatorImpl.Wrappers.TimeoutProvider(),
            tsAccountManager: DependenciesBridge.shared.tsAccountManager,
            udManager: RegistrationCoordinatorImpl.Wrappers.UDManager(SSKEnvironment.shared.udManagerRef),
            usernameApiClient: RegistrationCoordinatorImpl.Wrappers.UsernameApiClient(DependenciesBridge.shared.usernameApiClient),
            usernameLinkManager: DependenciesBridge.shared.usernameLinkManager
        )
    }
}
