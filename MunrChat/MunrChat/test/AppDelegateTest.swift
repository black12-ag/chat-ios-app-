//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import MunrChat

class AppDelegateTest: XCTestCase {
    func testApplicationShortcutItems() throws {
        func hasNewMessageShortcut(_ shortcuts: [UIApplicationShortcutItem]) -> Bool {
            shortcuts.contains(where: { $0.type.contains("quickCompose") })
        }

        let unregistered = AppDelegate.applicationShortcutItems(isRegistered: false)
        XCTAssertFalse(hasNewMessageShortcut(unregistered))

        let registered = AppDelegate.applicationShortcutItems(isRegistered: true)
        XCTAssertTrue(hasNewMessageShortcut(registered))
    }
}
