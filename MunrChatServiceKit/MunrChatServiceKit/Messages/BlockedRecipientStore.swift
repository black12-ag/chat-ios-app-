//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import GRDB

struct BlockedRecipientStore {
    func blockedRecipientIds(tx: DBReadTransaction) throws -> [MunrChatRecipient.RowId] {
        let db = tx.database
        do {
            return try BlockedRecipient.fetchAll(db).map(\.recipientId)
        } catch {
            throw error.grdbErrorForLogging
        }
    }

    func isBlocked(recipientId: MunrChatRecipient.RowId, tx: DBReadTransaction) throws -> Bool {
        let db = tx.database
        do {
            return try BlockedRecipient.filter(key: recipientId).fetchOne(db) != nil
        } catch {
            throw error.grdbErrorForLogging
        }
    }

    func setBlocked(_ isBlocked: Bool, recipientId: MunrChatRecipient.RowId, tx: DBWriteTransaction) throws {
        let db = tx.database
        do {
            if isBlocked {
                try BlockedRecipient(recipientId: recipientId).insert(db)
            } else {
                try BlockedRecipient(recipientId: recipientId).delete(db)
            }
        } catch DatabaseError.SQLITE_CONSTRAINT {
            // It's already blocked -- this is fine.
        } catch {
            throw error.grdbErrorForLogging
        }
    }

    func mergeRecipientId(_ recipientId: MunrChatRecipient.RowId, into targetRecipientId: MunrChatRecipient.RowId, tx: DBWriteTransaction) {
        do {
            if try self.isBlocked(recipientId: recipientId, tx: tx) {
                try self.setBlocked(true, recipientId: targetRecipientId, tx: tx)
            }
        } catch {
            Logger.warn("Couldn't merge BlockedRecipient")
        }
    }
}

struct BlockedRecipient: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName: String = "BlockedRecipient"

    let recipientId: MunrChatRecipient.RowId
}
