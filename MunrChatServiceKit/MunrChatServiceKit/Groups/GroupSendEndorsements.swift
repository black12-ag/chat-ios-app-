//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibMunrChatClient

struct GroupSendEndorsements {
    var secretParams: GroupSecretParams
    var expiration: Date
    var combined: GroupSendEndorsement
    var individual: [ServiceId: GroupSendEndorsement]

    func tokenBuilder(forServiceId serviceId: ServiceId) -> GroupSendFullTokenBuilder? {
        return individual[serviceId].map {
            return GroupSendFullTokenBuilder(secretParams: secretParams, expiration: expiration, endorsement: $0)
        }
    }
}
