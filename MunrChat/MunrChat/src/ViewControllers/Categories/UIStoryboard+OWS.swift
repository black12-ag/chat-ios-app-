//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import UIKit

extension UIStoryboard {
    private enum StoryboardName: String {
        case main = "Main"
    }

    class var main: UIStoryboard {
        return UIStoryboard(name: StoryboardName.main.rawValue, bundle: Bundle.main)
    }
}
