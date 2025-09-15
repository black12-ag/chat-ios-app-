//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibMunrChatClient

struct GroupSendFullTokenBuilder {
    var secretParams: GroupSecretParams
    var expiration: Date
    var endorsement: GroupSendEndorsement

    func build() -> GroupSendFullToken {
        return endorsement.toFullToken(groupParams: secretParams, expiration: expiration)
    }
}
