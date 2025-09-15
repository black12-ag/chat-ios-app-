//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#if TESTABLE_BUILD

import Foundation
import LibMunrChatClient

internal class MockMunrChatProtocolStore: MunrChatProtocolStore {
    public var sessionStore: MunrChatSessionStore { mockSessionStore }
    public var preKeyStore: PreKeyStoreImpl { mockPreKeyStore }
    public var signedPreKeyStore: SignedPreKeyStoreImpl { mockSignedPreKeyStore }
    public var kyberPreKeyStore: KyberPreKeyStoreImpl { mockKyberPreKeyStore }

    init(identity: OWSIdentity) {
        self.mockPreKeyStore = PreKeyStoreImpl(for: identity)
        self.mockSignedPreKeyStore = SignedPreKeyStoreImpl(for: identity)
        self.mockKyberPreKeyStore = KyberPreKeyStoreImpl(for: identity, dateProvider: Date.provider)
    }

    internal var mockSessionStore = MockSessionStore()
    internal var mockPreKeyStore: PreKeyStoreImpl
    internal var mockSignedPreKeyStore: SignedPreKeyStoreImpl
    internal var mockKyberPreKeyStore: KyberPreKeyStoreImpl
}

class MockSessionStore: MunrChatSessionStore {
    func mightContainSession(for recipient: MunrChatRecipient, tx: DBReadTransaction) -> Bool { false }
    func mergeRecipient(_ recipient: MunrChatRecipient, into targetRecipient: MunrChatRecipient, tx: DBWriteTransaction) { }
    func archiveAllSessions(for serviceId: ServiceId, tx: DBWriteTransaction) { }
    func archiveAllSessions(for address: MunrChatServiceAddress, tx: DBWriteTransaction) { }
    func archiveSession(for serviceId: ServiceId, deviceId: DeviceId, tx: DBWriteTransaction) { }
    func loadSession(for serviceId: ServiceId, deviceId: DeviceId, tx: DBReadTransaction) throws -> LibMunrChatClient.SessionRecord? { nil }
    func loadSession(for address: ProtocolAddress, context: StoreContext) throws -> LibMunrChatClient.SessionRecord? { nil }
    func resetSessionStore(tx: DBWriteTransaction) { }
    func deleteAllSessions(for serviceId: ServiceId, tx: DBWriteTransaction) { }
    func deleteAllSessions(for recipientUniqueId: RecipientUniqueId, tx: DBWriteTransaction) { }
    func removeAll(tx: DBWriteTransaction) { }
    func loadExistingSessions(for addresses: [ProtocolAddress], context: StoreContext) throws -> [LibMunrChatClient.SessionRecord] { [] }
    func storeSession(_ record: LibMunrChatClient.SessionRecord, for address: ProtocolAddress, context: StoreContext) throws { }
}

#endif
