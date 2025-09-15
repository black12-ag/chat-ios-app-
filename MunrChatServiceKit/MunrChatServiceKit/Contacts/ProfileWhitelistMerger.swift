//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

class ProfileWhitelistMerger: RecipientMergeObserver {
    private let profileManager: ProfileManager

    init(profileManager: ProfileManager) {
        self.profileManager = profileManager
    }

    func willBreakAssociation(for recipient: MunrChatRecipient, mightReplaceNonnilPhoneNumber: Bool, tx: DBWriteTransaction) {
        let tx = SDSDB.shimOnlyBridge(tx)
        profileManager.normalizeRecipientInProfileWhitelist(recipient, tx: tx)
    }

    func didLearnAssociation(mergedRecipient: MergedRecipient, tx: DBWriteTransaction) {
        if mergedRecipient.isLocalRecipient {
            return
        }
        let tx = SDSDB.shimOnlyBridge(tx)
        profileManager.normalizeRecipientInProfileWhitelist(mergedRecipient.newRecipient, tx: tx)
    }
}
