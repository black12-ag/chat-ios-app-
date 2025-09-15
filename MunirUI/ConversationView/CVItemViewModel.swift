//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

public import MunirServiceKit

public protocol CVItemViewModel: AnyObject {
    var interaction: TSInteraction { get }
    var contactShare: ContactShareViewModel? { get }
    var linkPreview: OWSLinkPreview? { get }
    var stickerAttachment: AttachmentStream? { get }
    var stickerMetadata: (any StickerMetadata)? { get }
    var isGiftBadge: Bool { get }
    var hasRenderableContent: Bool { get }
}
