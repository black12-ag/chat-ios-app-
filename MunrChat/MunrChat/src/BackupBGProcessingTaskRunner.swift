//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import MunrChatServiceKit

class BackupBGProcessingTaskRunner: BGProcessingTaskRunner {

    private let backgroundMessageFetcherFactory: () -> BackgroundMessageFetcherFactory
    private let backupSettingsStore: BackupSettingsStore
    private let db: DB
    private let exportJob: () -> BackupExportJob
    private let tsAccountManager: () -> TSAccountManager

    init(
        backgroundMessageFetcherFactory: @escaping () -> BackgroundMessageFetcherFactory,
        backupSettingsStore: BackupSettingsStore,
        db: SDSDatabaseStorage,
        exportJob: @escaping () -> BackupExportJob,
        tsAccountManager: @escaping () -> TSAccountManager,
    ) {
        self.backgroundMessageFetcherFactory = backgroundMessageFetcherFactory
        self.backupSettingsStore = backupSettingsStore
        self.db = db
        self.exportJob = exportJob
        self.tsAccountManager = tsAccountManager
    }

    // MARK: - BGProcessingTaskRunner

    public static let taskIdentifier = "BackupBGProcessingTaskRunner"

    public static let requiresNetworkConnectivity = true
    public static let requiresExternalPower = true

    func run() async throws {
        try await runWithChatConnection(
            backgroundMessageFetcherFactory: backgroundMessageFetcherFactory(),
            operation: {
                try await exportJob().exportAndUploadBackup(mode: .bgProcessingTask)
            }
        )
    }

    public func startCondition() -> BGProcessingTaskStartCondition {
        guard FeatureFlags.Backups.supported else {
            return .never
        }

        return db.read { (tx) -> BGProcessingTaskStartCondition in
            guard tsAccountManager().registrationState(tx: tx).isRegisteredPrimaryDevice else {
                return .never
            }

            switch backupSettingsStore.backupPlan(tx: tx) {
            case .disabled, .disabling:
                return .never
            case .free, .paid, .paidExpiringSoon, .paidAsTester:
                break
            }
            let lastBackupDate = (backupSettingsStore.lastBackupDate(tx: tx) ?? Date(millisecondsSince1970: 0))

            // Add in a little buffer so that we can roughly run at any time of
            // day, every day, but aren't always creeping forward with a strict
            // minimum. For example, if we run at 10pm one day then 9pm the next
            // is fine.
            return .after(lastBackupDate.addingTimeInterval(.day - (.hour * 4)))
        }
    }
}
