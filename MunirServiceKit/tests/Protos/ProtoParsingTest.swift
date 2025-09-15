//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
import MunirServiceKit

final class ProtoParsingTest: XCTestCase {
    func testProtoParsingInvalid() throws {
        XCTAssertThrowsError(try SSKProtoEnvelope(serializedData: Data()))
        XCTAssertThrowsError(try SSKProtoEnvelope(serializedData: Data([1, 2, 3])))
    }
}
