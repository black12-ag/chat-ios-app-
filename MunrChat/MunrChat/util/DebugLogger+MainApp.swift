//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import MunrChatServiceKit

extension DebugLogger {

    func postLaunchLogCleanup(appContext: MainAppContext) {
        let shouldWipeLogs: Bool = {
            guard let lastLaunchVersion = AppVersionImpl.shared.lastCompletedLaunchMainAppVersion else {
                // If we've never completed a main app launch, don't wipe.
                return false
            }
            return AppVersionNumber(lastLaunchVersion) < AppVersionNumber("6.16.0.0")
        }()
        if shouldWipeLogs {
            wipeLogsAlways(appContext: appContext)
            Logger.warn("Wiped logs")
        }
    }

    func wipeLogsAlways(appContext: MainAppContext) {
        disableFileLogging()

        // Only the main app can wipe logs because only the main app can access its
        // own logs. (The main app can wipe logs for the other extensions.)
        for dirPath in Self.allLogsDirPaths {
            do {
                try FileManager.default.removeItem(atPath: dirPath)
            } catch {
                owsFailDebug("Failed to delete log directory: \(error)")
            }
        }

        enableFileLogging(appContext: appContext, canLaunchInBackground: true)
    }
}
