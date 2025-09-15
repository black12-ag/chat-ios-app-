//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

#if TESTABLE_BUILD

open class AttachmentContentValidatorMock: AttachmentContentValidator {

    init() {}

    open func validateContents(
        dataSource: DataSource,
        shouldConsume: Bool,
        mimeType: String,
        renderingFlag: AttachmentReference.RenderingFlag,
        sourceFilename: String?
    ) async throws -> PendingAttachment {
        throw OWSAssertionError("Unimplemented")
    }

    open func validateContents(
        data: Data,
        mimeType: String,
        renderingFlag: AttachmentReference.RenderingFlag,
        sourceFilename: String?
    ) async throws -> PendingAttachment {
        throw OWSAssertionError("Unimplemented")
    }

    open func validateDownloadedContents(
        ofEncryptedFileAt fileUrl: URL,
        encryptionKey: Data,
        plaintextLength: UInt32?,
        integrityCheck: AttachmentIntegrityCheck,
        mimeType: String,
        renderingFlag: AttachmentReference.RenderingFlag,
        sourceFilename: String?
    ) async throws -> PendingAttachment {
        throw OWSAssertionError("Unimplemented")
    }

    open func reValidateContents(
        ofEncryptedFileAt fileUrl: URL,
        encryptionKey: Data,
        plaintextLength: UInt32,
        mimeType: String
    ) async throws -> RevalidatedAttachment {
        throw OWSAssertionError("Unimplemented")
    }

    open func validateContents(
        ofBackupMediaFileAt fileUrl: URL,
        outerDecryptionData: DecryptionMetadata,
        innerDecryptionData: DecryptionMetadata,
        finalEncryptionKey: Data,
        mimeType: String,
        renderingFlag: AttachmentReference.RenderingFlag,
        sourceFilename: String?
    ) async throws -> any PendingAttachment {
        throw OWSAssertionError("Unimplemented")
    }

    struct MockValidatedMessageBody: ValidatedMessageBody {
        var oversizeText: (any PendingAttachment)? { nil }
        let inlinedBody: MessageBody

        fileprivate init(inlinedBody: MessageBody) {
            self.inlinedBody = inlinedBody
        }
    }

    static func mockValidatedBody(_ body: String) -> ValidatedMessageBody {
        return MockValidatedMessageBody(inlinedBody: MessageBody(text: body, ranges: .empty))
    }

    open func truncatedMessageBodyForInlining(
        _ body: MessageBody,
        tx: DBWriteTransaction
    ) -> ValidatedInlineMessageBody {
        return MockValidatedMessageBody(inlinedBody: body)
    }

    open func prepareOversizeTextsIfNeeded<Key: Hashable>(
        from texts: [Key: MessageBody],
        encryptionKeys: [Key: Data],
    ) async throws -> [Key: ValidatedMessageBody] {
        throw OWSAssertionError("Unimplemented")
    }

    open func prepareQuotedReplyThumbnail(
        fromOriginalAttachment: AttachmentStream,
        originalReference: AttachmentReference
    ) async throws -> QuotedReplyAttachmentDataSource {
        throw OWSAssertionError("Unimplemented")
    }

    open func prepareQuotedReplyThumbnail(
        fromOriginalAttachmentStream: AttachmentStream
    ) async throws -> PendingAttachment {
        throw OWSAssertionError("Unimplemented")
    }
}

#endif
