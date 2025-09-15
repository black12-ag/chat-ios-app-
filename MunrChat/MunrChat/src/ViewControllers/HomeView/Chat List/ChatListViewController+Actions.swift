//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import MunrChatServiceKit

extension ChatListViewController {
    func selectPreviousConversation() {
        AssertIsOnMainThread()

        Logger.info("")

        // If we have presented a conversation list (the archive) navigate through that instead.
        if let presentedChatListViewController {
            presentedChatListViewController.selectPreviousConversation()
            return
        }

        let currentThread = self.conversationSplitViewController?.selectedThread
        if let previousIndexPath = renderState.indexPath(beforeThread: currentThread),
           let threadUniqueId = renderState.threadUniqueId(forIndexPath: previousIndexPath)
        {
            presentThread(threadUniqueId: threadUniqueId, action: .compose, animated: true)
        }
    }

    func selectNextConversation() {
        AssertIsOnMainThread()

        Logger.info("")

        // If we have presented a conversation list (the archive) navigate through that instead.
        if let presentedChatListViewController {
            presentedChatListViewController.selectNextConversation()
            return
        }

        let currentThread = self.conversationSplitViewController?.selectedThread
        if let nextIndexPath = renderState.indexPath(afterThread: currentThread),
           let threadUniqueId = renderState.threadUniqueId(forIndexPath: nextIndexPath)
        {
            presentThread(threadUniqueId: threadUniqueId, action: .compose, animated: true)
        }
    }

    func presentThread(
        threadUniqueId: String,
        action: ConversationViewAction = .none,
        focusMessageId: String? = nil,
        animated: Bool
    ) {
        conversationSplitViewController?.presentThread(
            threadUniqueId: threadUniqueId,
            action: action,
            focusMessageId: focusMessageId,
            animated: animated
        )
    }
}
