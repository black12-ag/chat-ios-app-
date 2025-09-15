//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import LibMunrChatClient

// This seed can be used to pre-generate the key group
// state before the group is created.  This allows us
// to preview the correct conversation color, etc. in
// the "new group" view.
public struct NewGroupSeed {

    public let groupSecretParams: GroupSecretParams

    public init() {
        let groupSecretParams = try! GroupSecretParams.generate()
        self.groupSecretParams = groupSecretParams
    }
}
