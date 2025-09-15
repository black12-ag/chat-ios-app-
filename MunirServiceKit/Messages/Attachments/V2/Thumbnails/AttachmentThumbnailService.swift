//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public protocol AttachmentThumbnailService {

    func thumbnailImage(
        for attachmentStream: AttachmentStream,
        quality: AttachmentThumbnailQuality
    ) async -> UIImage?

    func thumbnailImageSync(
        for attachmentStream: AttachmentStream,
        quality: AttachmentThumbnailQuality
    ) -> UIImage?

    func backupThumbnailData(image: UIImage) throws -> Data
}
