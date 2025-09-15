//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibMunrChatClient

struct MessageSenderRecipientErrors {
    var recipientErrors: [(serviceId: ServiceId, error: any Error)]

    func containsAny(of senderKeyErrors: MessageSender.SenderKeyError...) -> Bool {
        return recipientErrors.contains(where: { _, recipientError in
            return senderKeyErrors.contains(where: { $0 == (recipientError as? MessageSender.SenderKeyError) })
        })
    }
}
