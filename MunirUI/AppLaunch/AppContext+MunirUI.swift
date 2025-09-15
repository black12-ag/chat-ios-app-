//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import MunirServiceKit

public class AppContextUtils {

    private init() {}

    public static func openSystemSettingsAction(completion: (() -> Void)? = nil) -> ActionSheetAction? {
        guard CurrentAppContext().isMainApp else {
            return nil
        }

        return ActionSheetAction(title: CommonStrings.openSystemSettingsButton) { _ in
            CurrentAppContext().openSystemSettings()
            completion?()
        }
    }
}
