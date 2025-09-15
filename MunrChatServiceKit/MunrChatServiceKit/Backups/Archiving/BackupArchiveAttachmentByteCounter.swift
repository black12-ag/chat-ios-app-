//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public class BackupArchiveAttachmentByteCounter {
    private var bytesCounter: UInt64 = 0
    private var includedAttachmentsInByteCount: Set<Attachment.IDType> = Set()

    func addToByteCount(attachmentID: Attachment.IDType, byteCount: UInt64) {
        if includedAttachmentsInByteCount.contains(attachmentID) == false {
            bytesCounter += byteCount
            includedAttachmentsInByteCount.insert(attachmentID)
        }
    }

    func attachmentByteSize() -> UInt64 {
        bytesCounter
    }
}
