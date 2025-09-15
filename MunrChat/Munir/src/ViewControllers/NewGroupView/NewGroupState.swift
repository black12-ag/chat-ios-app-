//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import MunirServiceKit
import MunirUI

class NewGroupState {

    var groupSeed = NewGroupSeed()

    var recipientSet = OrderedSet<PickedRecipient>()

    var groupName: String?

    var avatarData: Data?

    func deriveNewGroupSeedForRetry() {
        groupSeed = NewGroupSeed()
    }

    var hasUnsavedChanges: Bool {
        return !recipientSet.isEmpty && groupName == nil && avatarData == nil
    }
}
