//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import MunirServiceKit

struct AppActivePrecondition: Precondition {
    private let _precondition: NotificationPrecondition

    init(appContext: AppContext) {
        self._precondition = NotificationPrecondition(
            notificationName: UIApplication.didBecomeActiveNotification,
            isSatisfied: { appContext.isAppForegroundAndActive() },
        )
    }

    func waitUntilSatisfied() async -> WaitResult {
        return await self._precondition.waitUntilSatisfied()
    }
}
