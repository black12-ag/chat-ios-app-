//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

extension BackupArchive {

    internal enum Constants {
        /// We reject downloading backup proto files larger than this.
        static let maxDownloadSizeBytes: UInt = 100 * 1024 * 1024 // 100 MiB
    }
}
