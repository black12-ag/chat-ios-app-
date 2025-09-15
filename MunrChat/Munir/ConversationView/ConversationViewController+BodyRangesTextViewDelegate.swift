//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

public import MunirServiceKit
public import MunirUI

extension ConversationViewController: BodyRangesTextViewDelegate {
    var supportsMentions: Bool { thread.allowsMentionSend }

    public func textViewDidBeginTypingMention(_ textView: BodyRangesTextView) {}

    public func textViewDidEndTypingMention(_ textView: BodyRangesTextView) {}

    public func textViewMentionPickerParentView(_ textView: BodyRangesTextView) -> UIView? {
        view
    }

    public func textViewMentionPickerReferenceView(_ textView: BodyRangesTextView) -> UIView? {
        bottomBar
    }

    public func textViewMentionPickerPossibleAddresses(_ textView: BodyRangesTextView, tx: DBReadTransaction) -> [SignalServiceAddress] {
        supportsMentions ? thread.recipientAddresses(with: SDSDB.shimOnlyBridge(tx)) : []
    }

    public func textViewMentionCacheInvalidationKey(_ textView: BodyRangesTextView) -> String {
        return thread.uniqueId
    }

    public func textViewDisplayConfiguration(_ textView: BodyRangesTextView) -> HydratedMessageBody.DisplayConfiguration {
        return .composing(textViewColor: textView.textColor)
    }

    public func mentionPickerStyle(_ textView: BodyRangesTextView) -> MentionPickerStyle {
        return .default
    }

    public func textViewDidInsertMemoji(_ memojiGlyph: OWSAdaptiveImageGlyph) {
        // Note: attachment might be nil or have an error at this point; that's fine.
        let attachment = SignalAttachment.attachmentFromMemoji(memojiGlyph)
        self.didPasteAttachments(attachment.map { [$0] })
    }
}
