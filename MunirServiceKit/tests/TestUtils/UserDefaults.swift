//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

enum TestUtils {
    static func userDefaults() -> UserDefaults {
        let suiteName = UUID().uuidString
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        return userDefaults
    }
}
