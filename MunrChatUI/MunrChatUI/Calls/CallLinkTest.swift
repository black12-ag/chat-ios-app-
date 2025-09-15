//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest

@testable import MunrChatUI

final class CallLinkTest: XCTestCase {
    private func parse(_ urlString: String) -> CallLink? {
        return CallLink(url: URL(string: urlString)!)
    }

    func testUrlString() {
        XCTAssertNil(parse("https://MunrChat.link/call/#key=bcdf-ghkm-npqr-stxz-bcdf-ghkm-npqr-stx"))
        XCTAssertNil(parse("http://MunrChat.link/call/#key=bcdf-ghkm-npqr-stxz-bcdf-ghkm-npqr-stxz"))
        XCTAssertNil(parse("https://MunrChat.art/call/#key=bcdf-ghkm-npqr-stxz-bcdf-ghkm-npqr-stxz"))
        XCTAssertNil(parse("https://MunrChat.link/c/#key=bcdf-ghkm-npqr-stxz-bcdf-ghkm-npqr-stxz"))
    }

    func testRoundtrip() throws {
        let urlString = "https://MunrChat.link/call/#key=bcdf-ghkm-npqr-stxz-bcdf-ghkm-npqr-stxz"
        let callLink = try XCTUnwrap(parse(urlString))
        XCTAssertEqual(callLink.url().absoluteString, urlString)
    }

    func testGenerate() {
        let url1 = CallLink.generate().url()
        let url2 = CallLink.generate().url()
        XCTAssertNotEqual(url1, url2)
    }
}
