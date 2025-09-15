//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
import MunrChatServiceKit

final class OWS2FAManagerTest: XCTestCase {
    func test_isWeakPin() {
        let strongPins = ["90210", "alphanumeric"]
        for pin in strongPins {
            XCTAssertFalse(OWS2FAManager.isWeakPin(pin), pin)
        }

        let weakPins = ["", "901", "123456", "654321", "222222", "①②③④⑤⑥"]
        for pin in weakPins {
            XCTAssertTrue(OWS2FAManager.isWeakPin(pin), pin)
        }
    }
}
