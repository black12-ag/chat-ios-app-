//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest

@testable import MunrChatServiceKit

class ErrorTest: XCTestCase {

    func testShortDescription() {
        let error = CocoaError(.fileReadNoSuchFile, userInfo: [ NSUnderlyingErrorKey: POSIXError(.ENOENT) ])
        XCTAssertEqual(error.shortDescription, "NSCocoaErrorDomain/260, NSPOSIXErrorDomain/2")
    }

}
