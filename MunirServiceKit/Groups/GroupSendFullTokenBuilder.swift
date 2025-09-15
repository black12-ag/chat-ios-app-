//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibSignalClient

struct GroupSendFullTokenBuilder {
    var secretParams: GroupSecretParams
    var expiration: Date
    var endorsement: GroupSendEndorsement

    func build() -> GroupSendFullToken {
        return endorsement.toFullToken(groupParams: secretParams, expiration: expiration)
    }
}
