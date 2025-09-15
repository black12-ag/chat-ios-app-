//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public enum LocalUserDisplayMode: UInt {
    // We should use this value by default.
    case asUser = 0
    case noteToSelf
    case asLocalUser
}
