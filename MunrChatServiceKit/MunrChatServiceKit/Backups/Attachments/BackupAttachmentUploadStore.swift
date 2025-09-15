//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import GRDB

public protocol BackupAttachmentUploadStore {

    /// "Enqueue" an attachment from a backup for upload.
    ///
    /// If the same attachment is already enqueued, updates it to the greater of the old and new owner's timestamp.
    ///
    /// Doesn't actually trigger an upload; callers must later call `fetchNextUpload`, complete the upload of
    /// both the fullsize and thumbnail as needed, and then call `removeQueuedUpload` once finished.
    /// Note that the upload operation can (and will) be separately durably enqueued in AttachmentUploadQueue,
    /// that's fine and doesn't change how this queue works.
    func enqueue(
        _ attachment: AttachmentStream,
        owner: QueuedBackupAttachmentUpload.OwnerType,
        fullsize: Bool,
        tx: DBWriteTransaction
    ) throws

    /// Read the next highest priority uploads off the queue, up to count.
    /// Returns an empty array if nothing is left to upload.
    /// Does NOT take into account minRetryTimestamp; callers are expected
    /// to handle results with timestamps greater than the current time.
    func fetchNextUploads(
        count: UInt,
        isFullsize: Bool,
        tx: DBReadTransaction
    ) throws -> [QueuedBackupAttachmentUpload]

    /// Remove the upload from the queue. Should be called once uploaded (or permanently failed).
    /// - returns the removed record, if any.
    @discardableResult
    func removeQueuedUpload(
        for attachmentId: Attachment.IDType,
        fullsize: Bool,
        tx: DBWriteTransaction
    ) throws -> QueuedBackupAttachmentUpload?
}

public class BackupAttachmentUploadStoreImpl: BackupAttachmentUploadStore {

    public init() {}

    public func enqueue(
        _ attachment: AttachmentStream,
        owner: QueuedBackupAttachmentUpload.OwnerType,
        fullsize: Bool,
        tx: DBWriteTransaction
    ) throws {
        let db = tx.database

        let unencryptedSize: UInt32
        if fullsize {
            unencryptedSize = attachment.unencryptedByteCount
        } else {
            // We don't (easily) know the thumbnail size; just estimate as the max size
            // (which is small anyway) and run with it.
            unencryptedSize = AttachmentThumbnailQuality.backupThumbnailMaxSizeBytes
        }

        var newRecord = QueuedBackupAttachmentUpload(
            attachmentRowId: attachment.id,
            highestPriorityOwnerType: owner,
            isFullsize: fullsize,
            estimatedByteCount: Cryptography.estimatedMediaTierCDNSize(
                unencryptedSize: unencryptedSize
            )
        )

        let existingRecord = try QueuedBackupAttachmentUpload
            .filter(Column(QueuedBackupAttachmentUpload.CodingKeys.attachmentRowId) == attachment.id)
            .filter(Column(QueuedBackupAttachmentUpload.CodingKeys.isFullsize) == fullsize)
            .fetchOne(db)

        if var existingRecord {
            // Only update if the new one has higher priority; otherwise leave untouched.
            if newRecord.highestPriorityOwnerType.isHigherPriority(than: existingRecord.highestPriorityOwnerType) {
                existingRecord.highestPriorityOwnerType = newRecord.highestPriorityOwnerType
                try existingRecord.update(db)
            }
        } else {
            // If there's no existing record, insert and we're done.
            try newRecord.checkAllUInt64FieldsFitInInt64()
            try newRecord.insert(db)
        }
    }

    public func fetchNextUploads(
        count: UInt,
        isFullsize: Bool,
        tx: DBReadTransaction
    ) throws -> [QueuedBackupAttachmentUpload] {
        // NULLS FIRST is unsupported in GRDB so we bridge to raw SQL;
        // we want thread wallpapers to go first (null timestamp) and then
        // descending order after that.
        return try QueuedBackupAttachmentUpload
            .fetchAll(
                tx.database,
                sql: """
                    SELECT * FROM \(QueuedBackupAttachmentUpload.databaseTableName)
                    WHERE \(QueuedBackupAttachmentUpload.CodingKeys.isFullsize.rawValue) = ?
                    ORDER BY
                        \(QueuedBackupAttachmentUpload.CodingKeys.maxOwnerTimestamp.rawValue) DESC NULLS FIRST
                    LIMIT ?
                    """,
                arguments: [isFullsize, count]
            )
    }

    @discardableResult
    public func removeQueuedUpload(
        for attachmentId: Attachment.IDType,
        fullsize: Bool,
        tx: DBWriteTransaction
    ) throws -> QueuedBackupAttachmentUpload? {
        let record = try QueuedBackupAttachmentUpload
            .filter(Column(QueuedBackupAttachmentUpload.CodingKeys.attachmentRowId) == attachmentId)
            .filter(Column(QueuedBackupAttachmentUpload.CodingKeys.isFullsize) == fullsize)
            .fetchOne(tx.database)
        try record?.delete(tx.database)
        return record
    }
}

extension QueuedBackupAttachmentUpload.OwnerType {

    public func isHigherPriority(than other: QueuedBackupAttachmentUpload.OwnerType) -> Bool {
        switch (self, other) {

        // Thread wallpapers are higher priority, they always win.
        case (.threadWallpaper, _):
            return true
        case (.message(_), .threadWallpaper):
            return false

        case (.message(let selfTimestamp), .message(let otherTimestamp)):
            // Higher priority if more recent.
            return selfTimestamp > otherTimestamp
        }
    }
}
