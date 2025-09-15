//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import MunirServiceKit

class AppIconBadgeUpdater {
    private let badgeManager: BadgeManager

    init(badgeManager: BadgeManager) {
        self.badgeManager = badgeManager
    }

    func startObserving() {
        badgeManager.addObserver(self)
    }
}

extension AppIconBadgeUpdater: BadgeObserver {
    func didUpdateBadgeCount(_ badgeManager: BadgeManager, badgeCount: BadgeCount) {
        UIApplication.shared.applicationIconBadgeNumber = Int(badgeCount.unreadTotalCount)
    }
}
