//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibMunrChatClient

@objc
public extension SSKProtoSyncMessageSent {
    var isStoryTranscript: Bool {
        storyMessage != nil || !storyMessageRecipients.isEmpty
    }
}

public extension SSKProtoEnvelope {
    @objc
    var sourceAddress: MunrChatServiceAddress? {
        return sourceServiceID.flatMap { (serviceIdString) -> MunrChatServiceAddress? in
            guard let serviceId = try? ServiceId.parseFrom(serviceIdString: serviceIdString) else {
                return nil
            }
            return MunrChatServiceAddress(serviceId)
        }
    }
}
