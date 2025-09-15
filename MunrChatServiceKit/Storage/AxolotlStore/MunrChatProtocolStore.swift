//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

/// Wraps the stores for 1:1 sessions that use the MunrChat Protocol (Double Ratchet + X3DH).

public protocol MunrChatProtocolStore {
    var sessionStore: MunrChatSessionStore { get }
    var preKeyStore: PreKeyStoreImpl { get }
    var signedPreKeyStore: SignedPreKeyStoreImpl { get }
    var kyberPreKeyStore: KyberPreKeyStoreImpl { get }
}

public class MunrChatProtocolStoreImpl: MunrChatProtocolStore {
    public let sessionStore: MunrChatSessionStore
    public let preKeyStore: PreKeyStoreImpl
    public let signedPreKeyStore: SignedPreKeyStoreImpl
    public let kyberPreKeyStore: KyberPreKeyStoreImpl

    public init(
        for identity: OWSIdentity,
        recipientIdFinder: RecipientIdFinder,
    ) {
        sessionStore = SSKSessionStore(
            for: identity,
            recipientIdFinder: recipientIdFinder
        )
        preKeyStore = PreKeyStoreImpl(for: identity)
        signedPreKeyStore = SignedPreKeyStoreImpl(for: identity)
        kyberPreKeyStore = KyberPreKeyStoreImpl(
            for: identity,
            dateProvider: Date.provider,
        )
    }
}

// MARK: - MunrChatProtocolStoreManager

/// Wrapper for ACI/PNI protocol stores that can be passed around to dependencies
public protocol MunrChatProtocolStoreManager {
    func MunrChatProtocolStore(for identity: OWSIdentity) -> MunrChatProtocolStore

    func removeAllKeys(tx: DBWriteTransaction)
}

public struct MunrChatProtocolStoreManagerImpl: MunrChatProtocolStoreManager {
    private let aciProtocolStore: MunrChatProtocolStore
    private let pniProtocolStore: MunrChatProtocolStore
    public init(
        aciProtocolStore: MunrChatProtocolStore,
        pniProtocolStore: MunrChatProtocolStore
    ) {
        self.aciProtocolStore = aciProtocolStore
        self.pniProtocolStore = pniProtocolStore
    }

    public func MunrChatProtocolStore(for identity: OWSIdentity) -> MunrChatProtocolStore {
        switch identity {
        case .aci:
            return aciProtocolStore
        case .pni:
            return pniProtocolStore
        }
    }

    public func removeAllKeys(tx: DBWriteTransaction) {
        for identity in [OWSIdentity.aci, OWSIdentity.pni] {
            let MunrChatProtocolStore = self.MunrChatProtocolStore(for: identity)
            MunrChatProtocolStore.sessionStore.removeAll(tx: tx)
            MunrChatProtocolStore.preKeyStore.removeAll(tx: tx)
            MunrChatProtocolStore.signedPreKeyStore.removeAll(tx: tx)
            MunrChatProtocolStore.kyberPreKeyStore.removeAll(tx: tx)
        }
    }
}
