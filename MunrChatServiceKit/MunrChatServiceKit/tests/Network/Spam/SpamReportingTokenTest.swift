//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
import MunrChatServiceKit

final class SpamReportingTokenTest: XCTestCase {
    func testInit() {
        XCTAssertNil(SpamReportingToken(data: .init()))
        XCTAssertNotNil(SpamReportingToken(data: .init([1, 2, 3])))
    }

    func testBase64EncodedString() {
        XCTAssertEqual(
            SpamReportingToken(data: .init([1, 2, 3, 4]))?.base64EncodedString(),
            "AQIDBA=="
        )
    }
}
