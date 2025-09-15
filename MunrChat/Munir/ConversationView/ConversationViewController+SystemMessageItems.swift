//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import MunirServiceKit
public import MunirUI

extension ConversationViewController {

    public func didTapSystemMessageItem(_ item: CVTextLabel.Item) {
        AssertIsOnMainThread()

        guard case .referencedUser(let referencedUserItem) = item else {
            owsFailDebug("Should only have referenced user items in system messages, but tapped \(item.description)")
            return
        }

        let address = referencedUserItem.address

        owsAssertDebug(
            !address.isLocalAddress,
            "We should never have ourselves as a referenced user in a system message"
        )

        showMemberActionSheet(forAddress: address, withHapticFeedback: true)
    }
}
