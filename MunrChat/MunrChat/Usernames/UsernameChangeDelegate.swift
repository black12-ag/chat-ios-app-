//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import MunrChatServiceKit

/// Represents an observer who should be notified immediately when username
/// state may have changed.
protocol UsernameChangeDelegate: AnyObject {
    func usernameStateDidChange(newState: Usernames.LocalUsernameState)
}
