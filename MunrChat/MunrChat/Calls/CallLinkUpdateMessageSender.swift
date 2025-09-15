//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import MunrChatServiceKit
import MunrChatRingRTC

final class CallLinkUpdateMessageSender {
    private let messageSenderJobQueue: MessageSenderJobQueue

    init(messageSenderJobQueue: MessageSenderJobQueue) {
        self.messageSenderJobQueue = messageSenderJobQueue
    }

    func sendCallLinkUpdateMessage(rootKey: CallLinkRootKey, adminPasskey: Data?, tx: DBWriteTransaction) {
        let localThread = TSContactThread.getOrCreateLocalThread(transaction: tx)!
        let callLinkUpdate = OutgoingCallLinkUpdateMessage(
            localThread: localThread,
            rootKey: rootKey,
            adminPasskey: adminPasskey,
            tx: tx
        )
        messageSenderJobQueue.add(message: .preprepared(transientMessageWithoutAttachments: callLinkUpdate), transaction: tx)
    }
}
