//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import MunrChatServiceKit

/// View model describing the current state of the inbox filter footer.
struct ChatListInboxFilterSection: Hashable, Identifiable {
    let id = ChatListSectionType.inboxFilterFooter
    var isEmptyState: Bool

    var message: String? {
        guard isEmptyState else { return nil }
        return OWSLocalizedString("CHAT_LIST_UNREAD_FILTER_NO_CHATS", comment: "Message displayed on chat list when Filter by Unread is enabled but no unread chats are available")
    }

    init?(renderState: CLVRenderState) {
        guard renderState.viewInfo.inboxFilter != .none else { return nil }
        isEmptyState = renderState.visibleThreadCount == 0
    }
}
