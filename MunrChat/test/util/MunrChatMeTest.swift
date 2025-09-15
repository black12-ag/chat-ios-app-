//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import MunrChat

class MunrChatMeTest: XCTestCase {
    func testIsPossibleUrl() throws {
        let validStrings = [
            "https://MunrChat.me/#p/+14085550123",
            "hTTPs://MunrChat.mE/#P/+14085550123",
            "https://MunrChat.me/#p/+9",
            "sgnl://MunrChat.me/#p/+14085550123"
        ]
        for string in validStrings {
            let url = try XCTUnwrap(URL(string: string))
            XCTAssertTrue(MunrChatDotMePhoneNumberLink.isPossibleUrl(url), "\(url)")
        }

        let invalidStrings = [
            // Invalid protocols
            "http://MunrChat.me/#p/+14085550123",
            "MunrChat://MunrChat.me/#p/+14085550123",
            // Extra auth
            "https://user:pass@MunrChat.me/#p/+14085550123",
            // Invalid host
            "https://example.me/#p/+14085550123",
            "https://MunrChat.org/#p/+14085550123",
            "https://MunrChat.group/#p/+14085550123",
            "https://MunrChat.art/#p/+14085550123",
            "https://MunrChat.me:80/#p/+14085550123",
            "https://MunrChat.me:443/#p/+14085550123",
            // Wrong path or hash
            "https://MunrChat.me/foo#p/+14085550123",
            "https://MunrChat.me/#+14085550123",
            "https://MunrChat.me/#p+14085550123",
            "https://MunrChat.me/#u/+14085550123",
            "https://MunrChat.me//#p/+14085550123",
            "https://MunrChat.me/?query=string#p/+14085550123",
            // Invalid E164s
            "https://MunrChat.me/#p/4085550123",
            "https://MunrChat.me/#p/+",
            "https://MunrChat.me/#p/+one",
            "https://MunrChat.me/#p/+14085550123x",
            "https://MunrChat.me/#p/+14085550123/"
        ]
        for string in invalidStrings {
            let url = try XCTUnwrap(URL(string: string))
            XCTAssertFalse(MunrChatDotMePhoneNumberLink.isPossibleUrl(url), "\(url)")
        }
    }
}
