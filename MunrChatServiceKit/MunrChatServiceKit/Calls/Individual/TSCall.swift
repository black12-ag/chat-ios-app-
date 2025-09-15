//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

// MARK: - RPRecentCallType

extension RPRecentCallType: CustomStringConvertible {
    public var description: String {
        NSStringFromCallType(self)
    }
}

// MARK: - OWSReadTracking

@objc
extension TSCall: OWSReadTracking {
    public var expireStartedAt: UInt64 {
        return 0
    }

    public func markAsRead(
        atTimestamp readTimestamp: UInt64,
        thread: TSThread,
        circumstance: OWSReceiptCircumstance,
        shouldClearNotifications: Bool,
        transaction tx: DBWriteTransaction
    ) {
        if wasRead {
            return
        }

        anyUpdateCall(transaction: tx) { callMessage in
            callMessage.wasRead = true
        }

        switch circumstance {
        case .onThisDevice, .onThisDeviceWhilePendingMessageRequest:
            let callRecordStore = DependenciesBridge.shared.callRecordStore
            let missedCallManager = DependenciesBridge.shared.callRecordMissedCallManager

            if
                let sqliteRowId = sqliteRowId,
                let associatedCallRecord = callRecordStore.fetch(
                    interactionRowId: sqliteRowId, tx: tx
                )
            {
                missedCallManager.markUnreadCallsInConversationAsRead(
                    beforeCallRecord: associatedCallRecord,
                    sendSyncMessage: true,
                    tx: tx
                )
            }
        case .onLinkedDevice, .onLinkedDeviceWhilePendingMessageRequest:
            break
        @unknown default:
            break
        }
    }
}
