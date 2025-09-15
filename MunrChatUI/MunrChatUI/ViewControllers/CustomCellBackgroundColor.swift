//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import UIKit

public protocol CustomBackgroundColorCell {
    func customBackgroundColor(forceDarkMode: Bool) -> UIColor
    func customSelectedBackgroundColor(forceDarkMode: Bool) -> UIColor
}
