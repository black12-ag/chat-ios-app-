//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
import MunrChatServiceKit

class TSGroupThreadTest: XCTestCase {
    func testHasSafetyNumbers() throws {
        let groupThread = try TSGroupThread(dictionary: [:])
        XCTAssertFalse(groupThread.hasSafetyNumbers())
    }
}
