//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import CoreServices
import Foundation
import MunirServiceKit
import UniformTypeIdentifiers

protocol VoiceMessageSendableDraft {
    func prepareForSending() throws -> URL
}

extension VoiceMessageSendableDraft {
    private func userVisibleFilename(currentDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSS"
        let dateString = dateFormatter.string(from: Date())
        return String(
            format: "signal-%@.%@",
            dateString,
            VoiceMessageConstants.fileExtension
        )
    }

    func prepareAttachment() throws -> SignalAttachment {
        let attachmentUrl = try prepareForSending()

        let dataSource = try DataSourcePath(fileUrl: attachmentUrl, shouldDeleteOnDeallocation: true)
        dataSource.sourceFilename = userVisibleFilename(currentDate: Date())

        let attachment = SignalAttachment.voiceMessageAttachment(dataSource: dataSource, dataUTI: UTType.mpeg4Audio.identifier)
        guard !attachment.hasError else {
            throw OWSAssertionError("Failed to create voice message attachment: \(attachment.errorName ?? "Unknown Error")")
        }
        return attachment
    }
}
