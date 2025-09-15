//
// Copyright 2025 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import Testing

@testable import MunirServiceKit

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
