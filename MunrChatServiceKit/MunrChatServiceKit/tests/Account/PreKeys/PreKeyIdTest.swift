//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest

@testable import MunrChatServiceKit

final class PreKeyIdTest: XCTestCase {
    func testMaximumRandomValue() {
        XCTAssertEqual(
            PreKeyId.nextPreKeyId(lastPreKeyId: 0, minimumCapacity: 0xFFFFFF),
            1
        )
    }

    func testMaximumNextValue() {
        XCTAssertEqual(
            PreKeyId.nextPreKeyId(lastPreKeyId: 0xFFFFFC, minimumCapacity: 3),
            0xFFFFFD
        )
    }

    func testWrapping() {
        XCTAssertEqual(
            PreKeyId.nextPreKeyId(lastPreKeyId: 0xFFFFFC, minimumCapacity: 4),
            1
        )
    }
}
