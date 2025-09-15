//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
import MunrChatServiceKit

final class GRDBDatabaseStorageAdapterTest: XCTestCase {
    func testWalFileUrl() throws {
        let input = URL(fileURLWithPath: "/tmp/foo.db")
        let expected = URL(fileURLWithPath: "/tmp/foo.db-wal")
        let actual = GRDBDatabaseStorageAdapter.walFileUrl(for: input)
        XCTAssertEqual(actual, expected)
    }

    func testShmFileUrl() throws {
        let input = URL(fileURLWithPath: "/tmp/foo.db")
        let expected = URL(fileURLWithPath: "/tmp/foo.db-shm")
        let actual = GRDBDatabaseStorageAdapter.shmFileUrl(for: input)
        XCTAssertEqual(actual, expected)
    }
}
