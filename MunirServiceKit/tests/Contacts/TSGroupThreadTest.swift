//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
import MunirServiceKit

class TSGroupThreadTest: XCTestCase {
    func testHasSafetyNumbers() throws {
        let groupThread = try TSGroupThread(dictionary: [:])
        XCTAssertFalse(groupThread.hasSafetyNumbers())
    }
}
