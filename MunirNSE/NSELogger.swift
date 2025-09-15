//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import MunirServiceKit

class NSELogger: PrefixedLogger {
    static let uncorrelated = NSELogger(prefix: "uncorrelated")

    convenience init() {
        self.init(
            prefix: "[NSE]",
            suffix: "{{\(UUID().uuidString)}}"
        )
    }
}
