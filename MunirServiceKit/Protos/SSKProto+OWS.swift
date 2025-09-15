//
// Copyright 2019 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibSignalClient

@objc
public extension SSKProtoSyncMessageSent {
    var isStoryTranscript: Bool {
        storyMessage != nil || !storyMessageRecipients.isEmpty
    }
}

public extension SSKProtoEnvelope {
    @objc
    var sourceAddress: SignalServiceAddress? {
        return sourceServiceID.flatMap { (serviceIdString) -> SignalServiceAddress? in
            guard let serviceId = try? ServiceId.parseFrom(serviceIdString: serviceIdString) else {
                return nil
            }
            return SignalServiceAddress(serviceId)
        }
    }
}
