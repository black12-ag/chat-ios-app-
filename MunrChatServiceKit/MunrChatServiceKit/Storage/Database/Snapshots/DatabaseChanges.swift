//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public protocol DatabaseChanges {
    typealias UniqueId = String
    typealias RowId = Int64

    var threadUniqueIds: Set<UniqueId> { get }
    /// Unique ids for threads that have been changed in a user-facing way
    /// that should affect the chat list UI.
    var threadUniqueIdsForChatListUpdate: Set<UniqueId> { get }
    var interactionUniqueIds: Set<UniqueId> { get }
    var storyMessageUniqueIds: Set<UniqueId> { get }
    var storyMessageRowIds: Set<RowId> { get }

    var interactionDeletedUniqueIds: Set<UniqueId> { get }
    var storyMessageDeletedUniqueIds: Set<UniqueId> { get }

    var tableNames: Set<String> { get }

    var tableRowIds: [String: Set<Int64>] { get }

    var didUpdateInteractions: Bool { get }

    var didUpdateThreads: Bool { get }

    func didUpdate(tableName: String) -> Bool

    func didUpdate(interaction: TSInteraction) -> Bool

    func didUpdate(thread: TSThread) -> Bool
}
