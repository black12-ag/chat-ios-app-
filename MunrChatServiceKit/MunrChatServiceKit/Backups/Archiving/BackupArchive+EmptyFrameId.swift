//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

extension BackupArchive {
    /// An identifier for an empty ``BackupProto_Frame``.
    ///
    /// Uses a singleton pattern, as frames do not contain their own ID and
    /// consequently all empty frames are equivalent.
    struct EmptyFrameId: BackupArchive.LoggableId {
        static let shared = EmptyFrameId()

        private init() {}

        // MARK: BackupArchive.LoggableId

        var typeLogString: String { "BackupArchiveFrame" }
        var idLogString: String { "Empty" }
    }
}
