//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import Testing

@testable import MunrChatServiceKit

struct TimeIntervalTest {
    @Test(arguments: [
        (.infinity, UInt64(Int64.max)),
        (.nan, 0),
        (-1.5, 0),
        (0.5, 500_000_000),
    ] as [(inputValue: TimeInterval, expectedValue: UInt64)])
    func testClampedNanoseconds(testCase: (inputValue: TimeInterval, expectedValue: UInt64)) {
        #expect(testCase.inputValue.clampedNanoseconds == testCase.expectedValue)
    }
}
