//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import GRDB

struct StoryRecipient: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName: String = "StoryRecipient"

    /// This *should* be a TSPrivateStoryThread. (The enforcement at the DB
    /// layer is "this is a thread").
    let threadId: TSThread.RowId
    let recipientId: MunrChatRecipient.RowId

    enum CodingKeys: String, CodingKey {
        case threadId
        case recipientId
    }
}
