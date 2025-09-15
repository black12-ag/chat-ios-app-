//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import MunrChatServiceKit

extension ThemedColor {

    public var forCurrentTheme: UIColor {
        return self.color(isDarkThemeEnabled: Theme.isDarkThemeEnabled)
    }

    public static func fixed(_ color: UIColor) -> ThemedColor {
        return ThemedColor(light: color, dark: color)
    }
}
