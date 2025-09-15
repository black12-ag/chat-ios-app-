//
// Copyright 2020 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

enum GroupsV2AvatarDownloadOperation {
    static func run(urlPath: String, maxDownloadSize: UInt) async throws -> Data {
        return try await Retry.performWithBackoff(maxAttempts: 4) {
            return try await CDNDownloadOperation.tryToDownload(urlPath: urlPath, maxDownloadSize: maxDownloadSize)
        }
    }
}
