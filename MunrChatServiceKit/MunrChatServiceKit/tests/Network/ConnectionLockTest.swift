//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import Testing

@testable import MunrChatServiceKit

struct ConnectionLockTest {
    @Test
    func testEachPriority() async throws {
        let filePath = OWSTemporaryDirectory().appendingPathComponent("\(UUID().uuidString).lock")
        for priority in 1...3 {
            let connectionLock = ConnectionLock(filePath: filePath, priority: priority, of: 3)
            defer { connectionLock.close() }
            // Ensure that we can lock, unlock, and then lock again.
            for _ in 1...2 {
                let heldLock = try await connectionLock.lock(onInterrupt: (.global(), {}))
                connectionLock.unlock(heldLock)
            }
        }
    }
}
