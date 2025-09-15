//
// Copyright 2020 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public extension Locale {
    var isCJKV: Bool {
        guard let languageCode = languageCode else { return false }
        return ["zk", "zh", "ja", "ko", "vi"].contains(languageCode)
    }
}
