//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public struct BackgroundMessageFetcherFactory {
    private let chatConnectionManager: any ChatConnectionManager
    private let groupMessageProcessorManager: GroupMessageProcessorManager
    private let messageFetcherJob: MessageFetcherJob
    private let messageProcessor: MessageProcessor
    private let messageSenderJobQueue: MessageSenderJobQueue
    private let receiptSender: ReceiptSender

    public init(
        chatConnectionManager: any ChatConnectionManager,
        groupMessageProcessorManager: GroupMessageProcessorManager,
        messageFetcherJob: MessageFetcherJob,
        messageProcessor: MessageProcessor,
        messageSenderJobQueue: MessageSenderJobQueue,
        receiptSender: ReceiptSender,
    ) {
        self.chatConnectionManager = chatConnectionManager
        self.groupMessageProcessorManager = groupMessageProcessorManager
        self.messageFetcherJob = messageFetcherJob
        self.messageProcessor = messageProcessor
        self.messageSenderJobQueue = messageSenderJobQueue
        self.receiptSender = receiptSender
    }

    public func buildFetcher(useWebSocket: Bool) -> BackgroundMessageFetcher {
        return BackgroundMessageFetcher(
            chatConnectionManager: self.chatConnectionManager,
            groupMessageProcessorManager: self.groupMessageProcessorManager,
            messageFetcherJob: self.messageFetcherJob,
            messageProcessor: self.messageProcessor,
            messageSenderJobQueue: self.messageSenderJobQueue,
            receiptSender: self.receiptSender,
            useWebSocket: useWebSocket,
        )
    }
}

public actor BackgroundMessageFetcher {
    private let chatConnectionManager: any ChatConnectionManager
    private let groupMessageProcessorManager: GroupMessageProcessorManager
    private let messageFetcherJob: MessageFetcherJob
    private let messageProcessor: MessageProcessor
    private let messageSenderJobQueue: MessageSenderJobQueue
    private let receiptSender: ReceiptSender
    private let useWebSocket: Bool

    fileprivate init(
        chatConnectionManager: any ChatConnectionManager,
        groupMessageProcessorManager: GroupMessageProcessorManager,
        messageFetcherJob: MessageFetcherJob,
        messageProcessor: MessageProcessor,
        messageSenderJobQueue: MessageSenderJobQueue,
        receiptSender: ReceiptSender,
        useWebSocket: Bool,
    ) {
        self.chatConnectionManager = chatConnectionManager
        self.groupMessageProcessorManager = groupMessageProcessorManager
        self.messageFetcherJob = messageFetcherJob
        self.messageProcessor = messageProcessor
        self.messageSenderJobQueue = messageSenderJobQueue
        self.receiptSender = receiptSender
        self.useWebSocket = useWebSocket
    }

    private var connectionTokens = [OWSChatConnection.ConnectionToken]()

    public func start() async {
        self.connectionTokens = chatConnectionManager.requestConnections()
        await self.groupMessageProcessorManager.startAllProcessors()
    }

    public func reset() {
        self.connectionTokens.forEach { $0.releaseConnection() }
        self.connectionTokens = []
    }

    /// Waits until message processing has reached an "idle" state.
    ///
    /// - Throws: An error when canceled or if the connection closes and won't
    /// immediately try to re-open.
    public func waitForFetchingProcessingAndSideEffects() async throws {
        try await withCooperativeRace(
            { try await self._waitForFetchingProcessingAndSideEffects() },
            { try await self.waitUntilSocketShouldBeClosedIfCanUseSockets() },
        )
    }

    /// Waits until `deadline`.
    ///
    /// - Throws: An error when canceled or if the connection closes and won't
    /// immediately try to re-open.
    public func waitUntil(deadline: MonotonicDate) async throws {
        let now = MonotonicDate()
        if now < deadline {
            try await withCooperativeRace(
                { try await Task.sleep(nanoseconds: (deadline - now).nanoseconds) },
                { try await self.waitUntilSocketShouldBeClosedIfCanUseSockets() },
            )
        }
    }

    private func waitUntilSocketShouldBeClosedIfCanUseSockets() async throws {
        if self.useWebSocket {
            try await self.chatConnectionManager.waitUntilIdentifiedConnectionShouldBeClosed()
            // We wanted to wait for things to happen, but we can't wait, so throw.
            throw OWSGenericError("Should be closed.")
        } else {
            // Just wait until this is canceled -- the socket will always be closed.
            let continuation = CancellableContinuation<Void>()
            return try await continuation.wait()
        }
    }

    private func _waitForFetchingProcessingAndSideEffects() async throws {
        try await messageProcessor.waitForFetchingAndProcessing()

        // Wait for these in parallel.
        do {
            // Wait until all ACKs are complete.
            async let pendingAcks: Void = self.messageFetcherJob.waitForPendingAcks()
            // Wait until all outgoing receipt sends are complete.
            async let pendingReceipts: Void = self.receiptSender.waitForPendingReceipts()
            // Wait until all outgoing messages are sent.
            async let pendingMessages: Void = self.messageSenderJobQueue.waitUntilDone()
            // Wait until all sync requests are fulfilled.
            async let pendingOps: Void = MessageReceiver.waitForPendingTasks()

            try await pendingAcks
            try await pendingReceipts
            try await pendingMessages
            try await pendingOps
        }

        // Finally, wait for any notifications to finish posting
        try await NotificationPresenterImpl.waitForPendingNotifications()
    }

    public func stopAndWaitBeforeSuspending() async {
        // Release the connections and wait for them to close.
        self.reset()
        await chatConnectionManager.waitForDisconnectIfClosed()

        // Wait for notifications that are already scheduled to be posted.
        do {
            try await NotificationPresenterImpl.waitForPendingNotifications()
        } catch {
            owsFailDebug("\(error)")
        }
    }
}
