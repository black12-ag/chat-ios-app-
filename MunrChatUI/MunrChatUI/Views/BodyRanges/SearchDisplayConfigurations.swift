//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

public import MunrChatServiceKit

extension HydratedMessageBody.DisplayConfiguration.SearchRanges {

    public static func matchedRanges(_ ranges: [NSRange]) -> Self {
        return HydratedMessageBody.DisplayConfiguration.SearchRanges(
            matchingBackgroundColor: .fixed(ConversationStyle.searchMatchHighlightColor),
            matchingForegroundColor: .fixed(.ows_black),
            matchedRanges: ranges
        )
    }
}
