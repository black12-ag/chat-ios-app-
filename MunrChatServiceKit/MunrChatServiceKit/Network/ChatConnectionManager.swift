//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import LibMunrChatClient

public protocol ChatConnectionManager {
    func updateCanOpenWebSocket()
    func waitForIdentifiedConnectionToOpen() async throws(CancellationError)
    func waitForUnidentifiedConnectionToOpen() async throws(CancellationError)
    /// Waits until we're no longer trying to open a web socket.
    ///
    /// - Note: If an existing socket gets interrupted but we'll try to
    /// re-connect, this will keep waiting. In other words, this waits until we
    /// are no longer capable of opening a socket (e.g., we are deregistered,
    /// all connection tokens are released).
    func waitUntilIdentifiedConnectionShouldBeClosed() async throws(CancellationError)
    @MainActor
    var unidentifiedConnectionState: OWSChatConnectionState { get }
    var hasEmptiedInitialQueue: Bool { get async }

    func shouldWaitForSocketToMakeRequest(connectionType: OWSChatConnectionType) -> Bool
    func shouldSocketBeOpen_restOnly(connectionType: OWSChatConnectionType) -> Bool
    func requestIdentifiedConnection() -> OWSChatConnection.ConnectionToken
    func requestUnidentifiedConnection() -> OWSChatConnection.ConnectionToken
    func waitForDisconnectIfClosed() async
    func makeRequest(_ request: TSRequest) async throws -> HTTPResponse

    func setRegistrationOverride(_ chatServiceAuth: ChatServiceAuth) async
    func clearRegistrationOverride() async
}

extension ChatConnectionManager {
    public func requestConnections() -> [OWSChatConnection.ConnectionToken] {
        return [
            requestIdentifiedConnection(),
            requestUnidentifiedConnection(),
        ]
    }
}

public class ChatConnectionManagerImpl: ChatConnectionManager {
    private let connectionIdentified: OWSAuthConnectionUsingLibMunrChat
    private let connectionUnidentified: OWSUnauthConnectionUsingLibMunrChat
    private var connections: [OWSChatConnection] { [ connectionIdentified, connectionUnidentified ]}

    @MainActor
    public init(
        accountManager: TSAccountManager,
        appContext: any AppContext,
        appExpiry: AppExpiry,
        appReadiness: AppReadiness,
        db: any DB,
        inactivePrimaryDeviceStore: InactivePrimaryDeviceStore,
        libMunrChatNet: Net,
        registrationStateChangeManager: RegistrationStateChangeManager,
    ) {
        self.connectionIdentified = OWSAuthConnectionUsingLibMunrChat(
            libMunrChatNet: libMunrChatNet,
            accountManager: accountManager,
            appContext: appContext,
            appExpiry: appExpiry,
            appReadiness: appReadiness,
            db: db,
            inactivePrimaryDeviceStore: inactivePrimaryDeviceStore,
            registrationStateChangeManager: registrationStateChangeManager,
        )
        self.connectionUnidentified = OWSUnauthConnectionUsingLibMunrChat(
            libMunrChatNet: libMunrChatNet,
            appExpiry: appExpiry,
            appReadiness: appReadiness,
            db: db,
        )

        SwiftSingletons.register(self)
    }

    private func connection(ofType type: OWSChatConnectionType) -> OWSChatConnection {
        switch type {
        case .identified:
            return connectionIdentified
        case .unidentified:
            return connectionUnidentified
        }
    }

    public func updateCanOpenWebSocket() {
        for connection in connections {
            connection.updateCanOpenWebSocket()
        }
    }

    public func shouldWaitForSocketToMakeRequest(connectionType: OWSChatConnectionType) -> Bool {
        return connection(ofType: connectionType).canOpenWebSocket
    }

    public func shouldSocketBeOpen_restOnly(connectionType: OWSChatConnectionType) -> Bool {
        return connection(ofType: connectionType).shouldSocketBeOpen_restOnly
    }

    public func waitForIdentifiedConnectionToOpen() async throws(CancellationError) {
        owsAssertBeta(OWSChatConnection.canAppUseSocketsToMakeRequests)
        try await self.connectionIdentified.waitForOpen()
    }

    public func waitForUnidentifiedConnectionToOpen() async throws(CancellationError) {
        owsAssertBeta(OWSChatConnection.canAppUseSocketsToMakeRequests)
        try await self.connectionUnidentified.waitForOpen()
    }

    public func waitUntilIdentifiedConnectionShouldBeClosed() async throws(CancellationError) {
        owsAssertBeta(OWSChatConnection.canAppUseSocketsToMakeRequests)
        try await self.connectionIdentified.waitUntilSocketShouldBeClosed()
    }

    public func requestIdentifiedConnection() -> OWSChatConnection.ConnectionToken {
        return connectionIdentified.requestConnection()
    }

    public func requestUnidentifiedConnection() -> OWSChatConnection.ConnectionToken {
        return connectionUnidentified.requestConnection()
    }

    public func waitForDisconnectIfClosed() async {
        await withTaskGroup { taskGroup in
            for connection in connections {
                taskGroup.addTask { await connection.waitForDisconnectIfClosed() }
            }
            await taskGroup.waitForAll()
        }
    }

    // This method can be called from any thread.
    public func makeRequest(_ request: TSRequest) async throws -> HTTPResponse {
        let connectionType = try request.auth.connectionType

        return try await connection(ofType: connectionType).makeRequest(request)
    }

    @MainActor
    public var unidentifiedConnectionState: OWSChatConnectionState {
        return connectionUnidentified.currentState
    }

    public var hasEmptiedInitialQueue: Bool {
        get async {
            return await connectionIdentified.hasEmptiedInitialQueue
        }
    }

    public func setRegistrationOverride(_ chatServiceAuth: ChatServiceAuth) async {
        await connectionIdentified.setRegistrationOverride(chatServiceAuth)
    }

    public func clearRegistrationOverride() async {
        await connectionIdentified.clearRegistrationOverride()
    }
}

#if TESTABLE_BUILD

public class ChatConnectionManagerMock: ChatConnectionManager {

    public init() {}

    public func updateCanOpenWebSocket() {
    }

    public var hasEmptiedInitialQueue: Bool = false

    public func waitForIdentifiedConnectionToOpen() async throws(CancellationError) {
    }

    public func waitForUnidentifiedConnectionToOpen() async throws(CancellationError) {
    }

    public func waitUntilIdentifiedConnectionShouldBeClosed() async throws(CancellationError) {
    }

    public var unidentifiedConnectionState: OWSChatConnectionState = .closed

    public var shouldWaitForSocketToMakeRequestPerType = [OWSChatConnectionType: Bool]()

    public func shouldWaitForSocketToMakeRequest(connectionType: OWSChatConnectionType) -> Bool {
        return shouldWaitForSocketToMakeRequestPerType[connectionType] ?? true
    }

    public func shouldSocketBeOpen_restOnly(connectionType: OWSChatConnectionType) -> Bool {
        fatalError()
    }

    public func requestIdentifiedConnection() -> OWSChatConnection.ConnectionToken {
        fatalError()
    }

    public func requestUnidentifiedConnection() -> OWSChatConnection.ConnectionToken {
        fatalError()
    }

    public func waitForDisconnectIfClosed() async {
    }

    public var requestHandler: (_ request: TSRequest) async throws -> HTTPResponse = { _ in
        fatalError("must override for tests")
    }

    public func makeRequest(_ request: TSRequest) async throws -> HTTPResponse {
        return try await requestHandler(request)
    }

    public func setRegistrationOverride(_ chatServiceAuth: ChatServiceAuth) async {
    }

    public func clearRegistrationOverride() async {
    }
}

#endif
