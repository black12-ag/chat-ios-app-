//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

#if TESTABLE_BUILD

open class MockAttachmentThumbnailService: AttachmentThumbnailService {

    public init() {}

    open func thumbnailImage(
        for attachmentStream: AttachmentStream,
        quality: AttachmentThumbnailQuality
    ) async -> UIImage? {
        return nil
    }

    open func thumbnailImageSync(
        for attachmentStream: AttachmentStream,
        quality: AttachmentThumbnailQuality
    ) -> UIImage? {
        return nil
    }

    open func backupThumbnailData(image: UIImage) throws -> Data {
        return Data()
    }
}

#endif
