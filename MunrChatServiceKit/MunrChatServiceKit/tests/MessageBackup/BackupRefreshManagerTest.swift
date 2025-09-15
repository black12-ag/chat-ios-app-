//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Testing

@testable import MunrChatServiceKit

@MainActor
struct BackupRefreshManagerTest {
    private let backupSettingsStore: BackupSettingsStore
    private let db: InMemoryDB
    private let accountKeyStore: AccountKeyStore
    private let mockNetworkManager: MockNetworkManager
    private let mockBackupRefreshManager: BackupRefreshManager

    init() {
        self.backupSettingsStore = BackupSettingsStore()
        self.db = InMemoryDB()
        self.accountKeyStore = AccountKeyStore(
            backupSettingsStore: backupSettingsStore,
        )
        self.mockNetworkManager = MockNetworkManager()
        self.mockBackupRefreshManager = BackupRefreshManager(
            accountKeyStore: accountKeyStore,
            backupRequestManager: BackupRequestManagerMock(),
            backupSettingsStore: backupSettingsStore,
            db: db,
            networkManager: mockNetworkManager,
            dateProvider: { Date() }
        )
    }

    var refreshSuccessResponse: (TSRequest, Bool, NetworkManager.RetryPolicy) async throws -> HTTPResponse = { request, _, _ in
        if request.url.absoluteString.hasSuffix("v1/archives") {
            return HTTPResponseImpl(requestUrl: request.url, status: 204, headers: HttpHeaders(), bodyData: Data())
        }
        throw OWSAssertionError("")
    }

    @Test
    func testMissingBackupTriggersRefresh() async throws {
        let testStart = Date()

        // Set up.
        db.write { tx in
            backupSettingsStore.setBackupPlan(.free, tx: tx)
            accountKeyStore.setAccountEntropyPool(AccountEntropyPool(), tx: tx)
            #expect(backupSettingsStore.lastBackupRefreshDate(tx: tx) == nil)
        }
        mockNetworkManager.asyncRequestHandlers.append(refreshSuccessResponse)
        mockNetworkManager.asyncRequestHandlers.append(refreshSuccessResponse)

        try await mockBackupRefreshManager.refreshBackupIfNeeded(localIdentifiers: LocalIdentifiers.forUnitTests, auth: .implicit())

        db.read { tx in
            #expect(
                backupSettingsStore.lastBackupRefreshDate(tx: tx) ?? Date.distantPast > testStart,
                "Refresh date should update"
            )
        }
    }

    @Test
    func testOldBackupTriggersRefresh() async throws {
        let thirtyDaysAgo = Date(timeIntervalSinceNow: -5 * .day)
        let testStart = Date()

        // Set up.
        db.write { tx in
            backupSettingsStore.setBackupPlan(.free, tx: tx)
            accountKeyStore.setAccountEntropyPool(AccountEntropyPool(), tx: tx)
            backupSettingsStore.setLastBackupRefreshDate(thirtyDaysAgo, tx: tx)
        }
        mockNetworkManager.asyncRequestHandlers.append(refreshSuccessResponse)
        mockNetworkManager.asyncRequestHandlers.append(refreshSuccessResponse)

        try await mockBackupRefreshManager.refreshBackupIfNeeded(localIdentifiers: LocalIdentifiers.forUnitTests, auth: .implicit())

        db.read { tx in
            #expect(
                backupSettingsStore.lastBackupRefreshDate(tx: tx) ?? Date.distantPast > testStart,
                "Refresh date should update"
            )
        }
    }

    @Test
    func testRecentBackupIgnoresRefresh() async throws {
        let oneDayAgo = Date(timeIntervalSinceNow: -1 * .day)

        // Set up.
        db.write { tx in
            backupSettingsStore.setBackupPlan(.free, tx: tx)
            backupSettingsStore.setLastBackupRefreshDate(oneDayAgo, tx: tx)
            accountKeyStore.setAccountEntropyPool(AccountEntropyPool(), tx: tx)
        }
        mockNetworkManager.asyncRequestHandlers.append(refreshSuccessResponse)
        mockNetworkManager.asyncRequestHandlers.append(refreshSuccessResponse)

        try await mockBackupRefreshManager.refreshBackupIfNeeded(localIdentifiers: LocalIdentifiers.forUnitTests, auth: .implicit())

        db.read { tx in
            #expect(
                (backupSettingsStore.lastBackupRefreshDate(tx: tx) ?? Date.distantPast).timeIntervalSince1970 == oneDayAgo.timeIntervalSince1970,
                "Refresh date should not update since last backup was too recent"
            )
        }
    }

    @Test
    func testDisabledBackupIgnoresRefresh() async throws {
        let testStart = Date()

        // Set up.
        db.write { tx in
            backupSettingsStore.setBackupPlan(.disabled, tx: tx)
            accountKeyStore.setAccountEntropyPool(AccountEntropyPool(), tx: tx)
            #expect(backupSettingsStore.lastBackupRefreshDate(tx: tx) == nil)
        }
        mockNetworkManager.asyncRequestHandlers.append(refreshSuccessResponse)
        mockNetworkManager.asyncRequestHandlers.append(refreshSuccessResponse)

        try await mockBackupRefreshManager.refreshBackupIfNeeded(localIdentifiers: LocalIdentifiers.forUnitTests, auth: .implicit())

        db.read { tx in
            #expect(
                backupSettingsStore.lastBackupRefreshDate(tx: tx) ?? Date.distantPast < testStart,
                "Refresh date should not update since backups is disabled"
            )
        }
    }
}
