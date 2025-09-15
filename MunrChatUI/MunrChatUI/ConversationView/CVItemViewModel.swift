//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

public import MunrChatServiceKit

public protocol CVItemViewModel: AnyObject {
    var interaction: TSInteraction { get }
    var contactShare: ContactShareViewModel? { get }
    var linkPreview: OWSLinkPreview? { get }
    var stickerAttachment: AttachmentStream? { get }
    var stickerMetadata: (any StickerMetadata)? { get }
    var isGiftBadge: Bool { get }
    var hasRenderableContent: Bool { get }
}
