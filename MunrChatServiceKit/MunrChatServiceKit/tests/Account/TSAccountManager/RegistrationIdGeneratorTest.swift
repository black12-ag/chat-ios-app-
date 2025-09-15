//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import MunrChatServiceKit

final class RegistrationIdGeneratorTest: XCTestCase {
    func testGenerateRegistrationId() {
        var results = Set<UInt32>()
        for _ in 1...100 {
            let result = RegistrationIdGenerator.generate()
            XCTAssertGreaterThanOrEqual(result, 1)
            XCTAssertLessThanOrEqual(result, 0x3fff)
            results.insert(result)
        }
        XCTAssertGreaterThan(results.count, 25)
    }
}
