//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

/// Responsible for migrating Storage Service record encryption to use a
/// `recordIkm` stored in the Storage Service manifest.
public protocol StorageServiceRecordIkmMigrator {

    /// Schedules a migration to encrypting Storage Service records using a
    /// `recordIkm` from the Storage Service manifest, if necessary.
    func migrateToManifestRecordIkmIfNecessary() async
}

struct StorageServiceRecordIkmMigratorImpl: StorageServiceRecordIkmMigrator {
    private let logger = PrefixedLogger(prefix: "[SSRecIkmMig]")

    private let db: any DB
    private let storageServiceManager: StorageServiceManager
    private let tsAccountManager: TSAccountManager

    init(
        db: any DB,
        storageServiceManager: StorageServiceManager,
        tsAccountManager: TSAccountManager
    ) {
        self.db = db
        self.storageServiceManager = storageServiceManager
        self.tsAccountManager = tsAccountManager
    }

    // MARK: -

    func migrateToManifestRecordIkmIfNecessary() async {
        /// If we're currently restoring, allow that to finish. We may be
        /// restoring (or creating) a manifest that contains a `recordIkm`,
        /// in which case there's nothing for us to do!
        try? await storageServiceManager.waitForPendingRestores()

        let (
            alreadyHasRecordIkm,
            isRegisteredPrimaryDevice
        ): (
            Bool,
            Bool
        ) = db.read { tx in
            return (
                storageServiceManager.currentManifestHasRecordIkm(tx: tx),
                tsAccountManager.registrationState(tx: tx).isRegisteredPrimaryDevice
            )
        }

        guard isRegisteredPrimaryDevice else {
            owsFailDebug(
                "Unexpectedly attempting to migrate to recordIkm, but not a primary device!",
                logger: logger
            )
            return
        }

        guard !alreadyHasRecordIkm else {
            return
        }

        logger.info("Rotating Storage Service manifest to ensure recordIkm is generated.")

        /// All we need to do is rotate the Storage Service manifest and
        /// referenced records. When we recreate a manifest and records (and the
        /// relevant capability is `true`, which we assert above) we will
        /// generate, store, and thereafter use a `recordIkm`.
        ///
        /// Note that rotating the manifest will send a sync message telling our
        /// other devices to fetch the latest manifest, and thereby learn about
        /// the `recordIkm` themselves.
        do {
            try await storageServiceManager.rotateManifest(
                mode: .alsoRotatingRecords,
                authedDevice: .implicit
            )

            logger.info("Successfully rotated Storage Service manifest.")

            owsAssertDebug(
                db.read { storageServiceManager.currentManifestHasRecordIkm(tx: $0) },
                "Unexpectedly missing recordIkm after Storage Service manifest rotation!",
                logger: logger
            )
        } catch {
            logger.error("Failed to rotate Storage Service manifest! \(error)")
        }
    }
}
