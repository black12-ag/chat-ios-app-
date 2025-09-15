//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibMunrChatClient

extension BackupArchive {

    public class AccountDataRestoringContext: RestoringContext {

        let currentRemoteConfig: RemoteConfig

        let backupPurpose: MessageBackupPurpose

        /// Will only be nil if there was no earier AccountData frame to set it, which
        /// should be treated as an error at read time when processing all subsequent frames.
        var backupPlan: BackupPlan?

        /// Will only be nil if there was no earier AccountData frame to set it, which
        /// should be treated as an error at read time when processing all subsequent frames.
        var uploadEra: String?

        init(
            startTimestampMs: UInt64,
            isPrimaryDevice: Bool,
            currentRemoteConfig: RemoteConfig,
            backupPurpose: MessageBackupPurpose,
            tx: DBWriteTransaction
        ) {
            self.currentRemoteConfig = currentRemoteConfig
            self.backupPurpose = backupPurpose
            super.init(
                startTimestampMs: startTimestampMs,
                isPrimaryDevice: isPrimaryDevice,
                tx: tx
            )
        }
    }
}
