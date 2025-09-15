//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import LibMunrChatClient

/// Describes a message that is being replied to in a draft.
public struct ThreadReplyInfo: Codable {
    public let timestamp: UInt64
    @AciUuid public var author: Aci

    public init(timestamp: UInt64, author: Aci) {
        self.timestamp = timestamp
        self._author = author.codableUuid
    }
}
