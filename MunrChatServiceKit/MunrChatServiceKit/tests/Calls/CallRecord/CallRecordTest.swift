//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest

@testable import MunrChatServiceKit

final class CallRecordTest: XCTestCase {
    func testNoOverlapBetweenStatuses() {
        let allIndividualStatusRawValues = CallRecord.CallStatus.IndividualCallStatus.allCases.map { $0.rawValue }
        let allGroupStatusRawValues = CallRecord.CallStatus.GroupCallStatus.allCases.map { $0.rawValue }

        XCTAssertFalse(
            Set(allIndividualStatusRawValues).intersects(Set(allGroupStatusRawValues))
        )
    }
}
