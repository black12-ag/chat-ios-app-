//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#if TESTABLE_BUILD

final class MockDeletedCallRecordCleanupManager: DeletedCallRecordCleanupManager {
    func startCleanupIfNecessary() async {}
}

#endif
