//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

extension AttachmentStream {

    public func asStickerMetadata(
        stickerInfo: StickerInfo,
        stickerType: StickerType,
        emojiString: String?
    ) -> any StickerMetadata {
        return EncryptedStickerMetadata.from(
            attachment: self,
            stickerInfo: stickerInfo,
            stickerType: stickerType,
            emojiString: emojiString
        )
    }
}
