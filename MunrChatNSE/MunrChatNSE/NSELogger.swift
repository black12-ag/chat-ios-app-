//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import MunrChatServiceKit

class NSELogger: PrefixedLogger {
    static let uncorrelated = NSELogger(prefix: "uncorrelated")

    convenience init() {
        self.init(
            prefix: "[NSE]",
            suffix: "{{\(UUID().uuidString)}}"
        )
    }
}
