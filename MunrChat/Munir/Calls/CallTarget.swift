//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibSignalClient
import MunirServiceKit
import MunirUI

enum CallTarget {
    case individual(TSContactThread)
    case groupThread(GroupIdentifier)
    case callLink(CallLink)
}

extension TSContactThread {
    var canCall: Bool {
        return !isNoteToSelf
    }
}

extension TSGroupThread {
    var canCall: Bool {
        return (
            isGroupV2Thread
            && groupMembership.isLocalUserFullMember
        )
    }
}
