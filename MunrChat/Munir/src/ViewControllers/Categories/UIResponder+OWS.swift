//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import UIKit

extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder?
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        // Passing `nil` to the to parameter of `sendAction` calls it on the firstResponder.
        UIApplication.shared.sendAction(#selector(findFirstResponder), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    @objc
    private func findFirstResponder() {
        UIResponder._currentFirstResponder = self
    }
}
