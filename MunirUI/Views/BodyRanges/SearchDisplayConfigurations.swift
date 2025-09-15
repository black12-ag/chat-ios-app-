//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

public import MunirServiceKit

extension HydratedMessageBody.DisplayConfiguration.SearchRanges {

    public static func matchedRanges(_ ranges: [NSRange]) -> Self {
        return HydratedMessageBody.DisplayConfiguration.SearchRanges(
            matchingBackgroundColor: .fixed(ConversationStyle.searchMatchHighlightColor),
            matchingForegroundColor: .fixed(.ows_black),
            matchedRanges: ranges
        )
    }
}
