//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest

@testable import MunrChatServiceKit

class MessageTimestampGeneratorTest: XCTestCase {
    func testGenerateTimestamp() {
        var nowMs: UInt64 = 0
        let generator = MessageTimestampGenerator(nowMs: { return nowMs })

        nowMs = 1
        let ts1 = generator.generateTimestamp()
        let ts2 = generator.generateTimestamp()
        nowMs = 2
        let ts3 = generator.generateTimestamp()
        nowMs = 4
        let ts4 = generator.generateTimestamp()

        XCTAssertEqual(ts1, 1)
        XCTAssertEqual(ts2, 2)
        XCTAssertEqual(ts3, 3)
        XCTAssertEqual(ts4, 4)
    }
}
