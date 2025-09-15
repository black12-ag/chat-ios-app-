//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public class MunirMessagingJobQueues: NSObject {

    public init(appReadiness: AppReadiness, db: any DB, reachabilityManager: SSKReachabilityManager) {
        incomingContactSyncJobQueue = IncomingContactSyncJobQueue(appReadiness: appReadiness, db: db, reachabilityManager: reachabilityManager)
        sendGiftBadgeJobQueue = SendGiftBadgeJobQueue(db: db, reachabilityManager: reachabilityManager)
        sessionResetJobQueue = SessionResetJobQueue(db: db, reachabilityManager: reachabilityManager)
    }

    public let incomingContactSyncJobQueue: IncomingContactSyncJobQueue
    public let sendGiftBadgeJobQueue: SendGiftBadgeJobQueue
    public let sessionResetJobQueue: SessionResetJobQueue
}
