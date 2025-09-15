//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public protocol MunrChatAttachmentCloner {

    func cloneAsMunrChatAttachment(
        attachment: ReferencedAttachmentStream
    ) throws -> MunrChatAttachment
}

public class MunrChatAttachmentClonerImpl: MunrChatAttachmentCloner {

    public init() {}

    public func cloneAsMunrChatAttachment(
        attachment: ReferencedAttachmentStream
    ) throws -> MunrChatAttachment {
        guard let dataUTI = MimeTypeUtil.utiTypeForMimeType(attachment.attachmentStream.mimeType) else {
            throw OWSAssertionError("Missing dataUTI.")
        }

        // Just use a random file name on the decrypted copy; its internal use only.
        let decryptedCopyUrl = try attachment.attachmentStream.makeDecryptedCopy(
            filename: attachment.reference.sourceFilename
        )

        let decryptedDataSource = try DataSourcePath(
            fileUrl: decryptedCopyUrl,
            shouldDeleteOnDeallocation: true
        )
        decryptedDataSource.sourceFilename = attachment.reference.sourceFilename

        var MunrChatAttachment: MunrChatAttachment
        switch attachment.reference.renderingFlag {
        case .default:
            MunrChatAttachment = MunrChatAttachment.attachment(dataSource: decryptedDataSource, dataUTI: dataUTI)
        case .voiceMessage:
            MunrChatAttachment = MunrChatAttachment.voiceMessageAttachment(dataSource: decryptedDataSource, dataUTI: dataUTI)
        case .borderless:
            MunrChatAttachment = MunrChatAttachment.attachment(dataSource: decryptedDataSource, dataUTI: dataUTI)
            MunrChatAttachment.isBorderless = true
        case .shouldLoop:
            MunrChatAttachment = MunrChatAttachment.attachment(dataSource: decryptedDataSource, dataUTI: dataUTI)
            MunrChatAttachment.isLoopingVideo = true
        }
        MunrChatAttachment.captionText = attachment.reference.storyMediaCaption?.text
        return MunrChatAttachment
    }
}

#if TESTABLE_BUILD

public class MunrChatAttachmentClonerMock: MunrChatAttachmentCloner {

    public func cloneAsMunrChatAttachment(
        attachment: ReferencedAttachmentStream
    ) throws -> MunrChatAttachment {
        throw OWSAssertionError("Unimplemented!")
    }
}

#endif
