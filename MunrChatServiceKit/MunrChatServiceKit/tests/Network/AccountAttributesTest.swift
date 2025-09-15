//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest

@testable import MunrChatServiceKit

final class AccountAttributesTest: XCTestCase {
    func testCapabilitiesRequestParameters() {
        let capabilities = AccountAttributes.Capabilities(hasSVRBackups: true)
        let requestParameters = capabilities.requestParameters
        // All we care about is that the prior line didn't crash.
        XCTAssertGreaterThanOrEqual(requestParameters.count, 0)
    }
}
