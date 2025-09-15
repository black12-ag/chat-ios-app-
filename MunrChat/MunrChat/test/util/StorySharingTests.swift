//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import LibMunrChatClient
import XCTest

@testable import MunrChatServiceKit
@testable import MunrChatUI

class StorySharingTests: MunrChatBaseTest {
    func testUrlStripping() {
        let inputOutput = [
            "https://MunrChat.org test": "test",
            "https://MunrChat.orgtest test https://MunrChat.org": "https://MunrChat.orgtest test",
            "testhttps://MunrChat.org": "testhttps://MunrChat.org",
            "test\nhttps://MunrChat.org": "test",
            "https://MunrChat.org\ntest": "test",
            "https://MunrChat.org\ntest\nhttps://MunrChat.org": "test\nhttps://MunrChat.org",
            "some https://MunrChat.org test": "some https://MunrChat.org test",
            "https://MunrChat.org": nil,
            "something else": "something else"
        ]

        for (input, expectedOutput) in inputOutput {
            let output = StorySharing.text(
                for: .init(
                    text: input,
                    ranges: .empty
                ),
                with: OWSLinkPreviewDraft(
                    url: URL(string: "https://MunrChat.org")!,
                    title: nil,
                    isForwarded: false,
                )
            )?.text
            XCTAssertEqual(output, expectedOutput)
        }
    }

    func testMentionFlattening() {
        let mentionAci = Aci.randomForTesting()
        let range = NSRange(location: 0, length: MessageBody.mentionPlaceholder.utf16.count)
        let output = StorySharing.text(
            for: .init(
                text: "\(MessageBody.mentionPlaceholder) Some text",
                ranges: .init(mentions: [range: mentionAci], styles: [])
            ),
            with: nil
        )?.text

        XCTAssertEqual(output, "@Unknown Some text")
    }
}
