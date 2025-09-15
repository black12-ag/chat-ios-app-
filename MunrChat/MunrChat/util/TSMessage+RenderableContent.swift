//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

public import MunrChatServiceKit

extension TSMessage {

    /// Dangerous to use for uninserted messages; exposed only in the MunrChat target because most rendering
    /// uses already-inserted messages, obviating the concern.
    public func hasRenderableContent(tx: DBReadTransaction) -> Bool {
        guard let rowId = self.sqliteRowId else {
            owsFailDebug("Checking renderable content for uninserted message!")
            return TSMessageBuilder.hasRenderableContent(
                hasNonemptyBody: body?.nilIfEmpty != nil,
                hasBodyAttachmentsOrOversizeText: false,
                hasLinkPreview: linkPreview != nil,
                hasQuotedReply: quotedMessage != nil,
                hasContactShare: contactShare != nil,
                hasSticker: messageSticker != nil,
                hasGiftBadge: giftBadge != nil,
                isStoryReply: isStoryReply,
                isPaymentMessage: (self is OWSPaymentMessage || self is OWSArchivedPaymentMessage),
                storyReactionEmoji: storyReactionEmoji
            )
        }
        return insertedMessageHasRenderableContent(rowId: rowId, tx: tx)
    }
}
