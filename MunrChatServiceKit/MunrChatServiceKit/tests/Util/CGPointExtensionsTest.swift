//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
import MunrChatServiceKit

class CGPointExtensionsTest: XCTestCase {
    func testPlusEquals() throws {
        var point = CGPoint(x: 1, y: 2)
        point += CGPoint(x: 3, y: 4)
        XCTAssertEqual(point, CGPoint(x: 4, y: 6))
    }

    func testTimesEquals() throws {
        var point = CGPoint(x: 1, y: 2)
        point *= 2
        XCTAssertEqual(point, CGPoint(x: 2, y: 4))
    }
}
