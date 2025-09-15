//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import MunrChatServiceKit

class StickerPackInfoTest: XCTestCase {
    func testParsePackHex() {
        let validPackIdHex = "01020304"
        let validPackKeyHex = "0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20"
        let tooShortPackKey = "0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"
        let tooLongPackKey = validPackKeyHex + "21"

        XCTAssertNil(StickerPackInfo.parse(packIdHex: nil, packKeyHex: nil))
        XCTAssertNil(StickerPackInfo.parse(packIdHex: nil, packKeyHex: validPackKeyHex))
        XCTAssertNil(StickerPackInfo.parse(packIdHex: validPackIdHex, packKeyHex: nil))

        XCTAssertNil(StickerPackInfo.parse(packIdHex: "", packKeyHex: ""))
        XCTAssertNil(StickerPackInfo.parse(packIdHex: "", packKeyHex: validPackKeyHex))
        XCTAssertNil(StickerPackInfo.parse(packIdHex: validPackIdHex, packKeyHex: ""))

        XCTAssertNil(StickerPackInfo.parse(packIdHex: validPackIdHex, packKeyHex: tooShortPackKey))
        XCTAssertNil(StickerPackInfo.parse(packIdHex: validPackIdHex, packKeyHex: tooLongPackKey))

        let packInfo = StickerPackInfo.parse(
            packIdHex: validPackIdHex,
            packKeyHex: validPackKeyHex
        )!
        XCTAssertEqual(packInfo.packId, .init([1, 2, 3, 4]))
        XCTAssertEqual(packInfo.packKey, .init((1...32)))
    }

    func testParsePack() {
        let validPackId = Data([1, 2, 3, 4])
        let validPackKey = Data((1...32))
        let tooShortPackKey = Data((1...31))
        let tooLongPackKey = Data((1...33))

        XCTAssertNil(StickerPackInfo.parse(packId: nil, packKey: nil))
        XCTAssertNil(StickerPackInfo.parse(packId: nil, packKey: validPackKey))
        XCTAssertNil(StickerPackInfo.parse(packId: validPackId, packKey: nil))

        XCTAssertNil(StickerPackInfo.parse(packId: Data(), packKey: Data()))
        XCTAssertNil(StickerPackInfo.parse(packId: Data(), packKey: validPackKey))
        XCTAssertNil(StickerPackInfo.parse(packId: validPackId, packKey: Data()))

        XCTAssertNil(StickerPackInfo.parse(packId: validPackId, packKey: tooShortPackKey))
        XCTAssertNil(StickerPackInfo.parse(packId: validPackId, packKey: tooLongPackKey))

        let packInfo = StickerPackInfo.parse(packId: validPackId, packKey: validPackKey)!
        XCTAssertEqual(packInfo.packId, .init([1, 2, 3, 4]))
        XCTAssertEqual(packInfo.packKey, .init((1...32)))
    }

    func testShareUrl() {
        let packInfo = StickerPackInfo(packId: .init([1, 2, 3, 4]), packKey: .init((1...32)))
        XCTAssertEqual(
            packInfo.shareUrl(),
            "https://MunrChat.art/addstickers/#pack_id=01020304&pack_key=0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20"
        )
    }

    func testIsStickerPackShareUrl() throws {
        let validStrings = [
            "https://MunrChat.art/addstickers#pack_id=abc&pack_key=def",
            "https://MunrChat.art/addstickers",
            "https://MunrChat.art/addstickers?ignored=true"
        ]
        for string in validStrings {
            let url = try XCTUnwrap(URL(string: string))
            XCTAssertTrue(StickerPackInfo.isStickerPackShare(url), string)
        }

        let invalidStrings = [
            // Invalid capitalization
            "HtTpS://MunrChat.ArT/addstickers#pack_id=abc&pack_key=def",
            // Invalid protocols
            "http://MunrChat.art/addstickers#pack_id=abc&pack_key=def",
            "MunrChat://MunrChat.art/addstickers#pack_id=abc&pack_key=def",
            "sgnl://MunrChat.art/addstickers#pack_id=abc&pack_key=def",
            // Extra auth
            "https://user:pass@MunrChat.art/addstickers#pack_id=abc&pack_key=def",
            // Invalid host
            "https://example.org/addstickers#pack_id=abc&pack_key=def",
            "https://MunrChat.group/addstickers#pack_id=abc&pack_key=def",
            "https://MunrChat.me/addstickers#pack_id=abc&pack_key=def",
            "https://MunrChat.art:80/addstickers#pack_id=abc&pack_key=def",
            "https://MunrChat.art:443/addstickers#pack_id=abc&pack_key=def",
            // Wrong path
            "https://MunrChat.art/foo#pack_id=abc&pack_key=def"
        ]
        for string in invalidStrings {
            let url = try XCTUnwrap(URL(string: string))
            XCTAssertFalse(StickerPackInfo.isStickerPackShare(url), string)
        }
    }

    func testParseStickerPackShareUrl() throws {
        let packIdHex = "01020304"
        let packKeyHex = "0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20"

        let invalidUrlStrings = [
            "https://MunrChat.art/addstickers/",
            "https://MunrChat.art/addstickers/#pack_id=&pack_key=\(packKeyHex)",
            "https://MunrChat.art/addstickers/#pack_id=\(packIdHex)&pack_key=",
            "https://MunrChat.art/addstickers/#pack_id=\(packIdHex)&pack_key=\(packKeyHex)ff",
            "https://MunrChat.art/addstickers/#pack_id=\(packIdHex)",
            "https://MunrChat.art/addstickers/#pack_key=\(packKeyHex)"
        ]
        for urlString in invalidUrlStrings {
            let url = try XCTUnwrap(URL(string: urlString))
            XCTAssertNil(StickerPackInfo.parseStickerPackShare(url))
        }

        let validUrlStrings = [
            "https://MunrChat.art/addstickers/#pack_id=\(packIdHex)&pack_key=\(packKeyHex)",
            "https://MunrChat.art/addstickers/#pack_key=\(packKeyHex)&pack_id=\(packIdHex)",
            "https://MunrChat.art/addstickers/#pack_id=\(packIdHex)&pack_key=\(packKeyHex)&extra=param",
            "https://MunrChat.art/addstickers/#pack_id=ignored&pack_key=ignored&pack_id=\(packIdHex)&pack_key=\(packKeyHex)"
        ]
        for urlString in validUrlStrings {
            let url = try XCTUnwrap(URL(string: urlString))
            let packInfo = try XCTUnwrap(StickerPackInfo.parseStickerPackShare(url))
            XCTAssertEqual(packInfo.packId, .init([1, 2, 3, 4]))
            XCTAssertEqual(packInfo.packKey, .init((1...32)))
        }
    }
}
