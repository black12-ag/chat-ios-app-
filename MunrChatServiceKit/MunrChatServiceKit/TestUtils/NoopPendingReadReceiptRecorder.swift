//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

public class NoopPendingReceiptRecorder: PendingReceiptRecorder {
    public func recordPendingReadReceipt(for message: TSIncomingMessage, thread: TSThread, transaction: DBWriteTransaction) {
        Logger.info("")
    }

    public func recordPendingViewedReceipt(for message: TSIncomingMessage, thread: TSThread, transaction: DBWriteTransaction) {
        Logger.info("")
    }
}
