//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

extension BackupArchive {

    public class ChatItemRestoringContext: RestoringContext {

        let chatContext: ChatRestoringContext
        let recipientContext: RecipientRestoringContext

        public var uploadEra: String? { chatContext.customChatColorContext.accountDataContext.uploadEra }

        init(
            chatContext: ChatRestoringContext,
            recipientContext: RecipientRestoringContext,
            startTimestampMs: UInt64,
            isPrimaryDevice: Bool,
            tx: DBWriteTransaction
        ) {
            self.recipientContext = recipientContext
            self.chatContext = chatContext
            super.init(
                startTimestampMs: startTimestampMs,
                isPrimaryDevice: isPrimaryDevice,
                tx: tx
            )
        }
    }
}
