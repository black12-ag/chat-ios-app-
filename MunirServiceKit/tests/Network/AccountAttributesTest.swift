//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import XCTest

@testable import MunirServiceKit

final class AccountAttributesTest: XCTestCase {
    func testCapabilitiesRequestParameters() {
        let capabilities = AccountAttributes.Capabilities(hasSVRBackups: true)
        let requestParameters = capabilities.requestParameters
        // All we care about is that the prior line didn't crash.
        XCTAssertGreaterThanOrEqual(requestParameters.count, 0)
    }
}
