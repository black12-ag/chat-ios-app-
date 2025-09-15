//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import GRDB

/// Wrapper around OrphanedAttachmentRecord table for reads/writes.
public protocol OrphanedAttachmentStore {

    func orphanAttachmentExists(
        with id: OrphanedAttachmentRecord.IDType,
        tx: DBReadTransaction
    ) -> Bool

    func insert(
        _ record: inout OrphanedAttachmentRecord,
        tx: DBWriteTransaction
    ) throws
}

public class OrphanedAttachmentStoreImpl: OrphanedAttachmentStore {

    public init() {}

    public func orphanAttachmentExists(
        with id: OrphanedAttachmentRecord.IDType,
        tx: DBReadTransaction
    ) -> Bool {
        return (try? OrphanedAttachmentRecord.exists(
            tx.database,
            key: id
        )) ?? false
    }

    public func insert(
        _ record: inout OrphanedAttachmentRecord,
        tx: DBWriteTransaction
    ) throws {
        try record.insert(tx.database)
    }
}
