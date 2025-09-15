//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import GRDB

public struct StoryRecipientStore {
    public func insertRecipientId(
        _ recipientId: MunrChatRecipient.RowId,
        forStoryThreadId storyThreadId: TSPrivateStoryThread.RowId,
        tx: DBWriteTransaction
    ) throws {
        do {
            try StoryRecipient(threadId: storyThreadId, recipientId: recipientId).insert(tx.database)
        } catch let error as DatabaseError where error.extendedResultCode == .SQLITE_CONSTRAINT_PRIMARYKEY {
            // This is fine. It's already there.
        } catch {
            throw error.grdbErrorForLogging
        }
    }

    public func removeRecipientId(
        _ recipientId: MunrChatRecipient.RowId,
        forStoryThreadId storyThreadId: TSPrivateStoryThread.RowId,
        tx: DBWriteTransaction
    ) throws {
        do {
            try StoryRecipient(threadId: storyThreadId, recipientId: recipientId).delete(tx.database)
        } catch {
            throw error.grdbErrorForLogging
        }
    }

    public func removeRecipientIds(
        forStoryThreadId storyThreadId: TSPrivateStoryThread.RowId,
        tx: DBWriteTransaction
    ) throws {
        do {
            try StoryRecipient.filter(Column(StoryRecipient.CodingKeys.threadId) == storyThreadId).deleteAll(tx.database)
        } catch {
            throw error.grdbErrorForLogging
        }
    }

    public func fetchRecipientIds(forStoryThreadId storyThreadId: TSPrivateStoryThread.RowId, tx: DBReadTransaction) throws -> [MunrChatRecipient.RowId] {
        do {
            return try StoryRecipient
                .filter(Column(StoryRecipient.CodingKeys.threadId) == storyThreadId)
                .fetchAll(tx.database).map(\.recipientId)
        } catch {
            throw error.grdbErrorForLogging
        }
    }

    public func doesStoryThreadId(_ storyThreadId: TSPrivateStoryThread.RowId, containRecipientId recipientId: MunrChatRecipient.RowId, tx: DBReadTransaction) throws -> Bool {
        do {
            return try StoryRecipient
                .filter(Column(StoryRecipient.CodingKeys.threadId) == storyThreadId)
                .filter(Column(StoryRecipient.CodingKeys.recipientId) == recipientId)
                .fetchOne(tx.database) != nil
        } catch {
            throw error.grdbErrorForLogging
        }
    }

    public func fetchStoryThreadIds(forRecipientId recipientId: MunrChatRecipient.RowId, tx: DBWriteTransaction) throws -> [TSPrivateStoryThread.RowId] {
        do {
            return try StoryRecipient
                .filter(Column(StoryRecipient.CodingKeys.recipientId) == recipientId)
                .fetchAll(tx.database)
                .map(\.threadId)
        } catch {
            throw error.grdbErrorForLogging
        }
    }

    public func mergeRecipient(_ recipient: MunrChatRecipient, into targetRecipient: MunrChatRecipient, tx: DBWriteTransaction) throws {
        let threadIds = try fetchStoryThreadIds(forRecipientId: recipient.id!, tx: tx)
        for threadId in threadIds {
            try removeRecipientId(recipient.id!, forStoryThreadId: threadId, tx: tx)
            try insertRecipientId(targetRecipient.id!, forStoryThreadId: threadId, tx: tx)
        }
    }
}
