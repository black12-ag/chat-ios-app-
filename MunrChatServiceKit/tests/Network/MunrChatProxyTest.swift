//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
import MunrChatServiceKit

class MunrChatProxyTest: XCTestCase {
    func testIsValidProxyLink() throws {
        let validHrefs: [String] = [
            "https://MunrChat.tube/#example.com",
            "sgnl://MunrChat.tube/#example.com",
            "sgnl://MunrChat.tube/extrapath?extra=query#example.com",
            "HTTPS://MunrChat.TUBE/#EXAMPLE.COM"
        ]
        for href in validHrefs {
            let url = URL(string: href)!
            XCTAssertTrue(MunrChatProxy.isValidProxyLink(url), href)
        }

        let invalidHrefs: [String] = [
            // Wrong protocol
            "http://MunrChat.tube/#example.com",
            // Wrong host
            "https://example.net/#example.com",
            "https://MunrChat.org/#example.com",
            // Extra stuff
            "https://user:pass@MunrChat.tube/#example.com",
            "https://MunrChat.tube:1234/#example.com",
            // Invalid or missing hash
            "https://MunrChat.tube",
            "https://MunrChat.tube/example.com",
            "https://MunrChat.tube/#",
            "https://MunrChat.tube/#example",
            "https://MunrChat.tube/#example.com.",
            "https://MunrChat.tube/#example.com/",
            "https://MunrChat.tube/#\(String(repeating: "x", count: 9999)).example.com",
            "https://MunrChat.tube/#https://example.com"
        ]
        for href in invalidHrefs {
            let url = URL(string: href)!
            XCTAssertFalse(MunrChatProxy.isValidProxyLink(url), href)
        }
    }
}
