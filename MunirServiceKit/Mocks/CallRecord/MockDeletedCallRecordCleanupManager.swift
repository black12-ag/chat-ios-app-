//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

#if TESTABLE_BUILD

final class MockDeletedCallRecordCleanupManager: DeletedCallRecordCleanupManager {
    func startCleanupIfNecessary() async {}
}

#endif
