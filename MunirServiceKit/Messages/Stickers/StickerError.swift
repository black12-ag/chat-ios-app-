//
// Copyright 2019 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

@objc
public enum StickerError: Int, Error, IsRetryableProvider {
    case invalidInput
    case noSticker
    case corruptData

    // MARK: - IsRetryableProvider

    public var isRetryableProvider: Bool { false }
}
