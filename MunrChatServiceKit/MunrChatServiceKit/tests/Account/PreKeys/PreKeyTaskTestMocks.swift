//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibMunrChatClient

@testable import MunrChatServiceKit

//
//
// MARK: - Mocks
//
//
extension PreKey {
    enum Mocks {
        typealias APIClient = _PreKey_APIClientMock
        typealias DateProvider = _PreKey_DateProviderMock
        typealias IdentityManager = _PreKey_IdentityManagerMock
        typealias IdentityKeyMismatchManager = _PreKey_IdentityKeyMismatchManagerMock
    }
}

//
//
// MARK: - Mock Implementations
//
//

class _PreKey_IdentityManagerMock: PreKey.Shims.IdentityManager {

    var aciKeyPair: ECKeyPair?
    var pniKeyPair: ECKeyPair?

    func identityKeyPair(for identity: OWSIdentity, tx: MunrChatServiceKit.DBReadTransaction) -> ECKeyPair? {
        switch identity {
        case .aci:
            return aciKeyPair
        case .pni:
            return pniKeyPair
        }
    }

    func generateNewIdentityKeyPair() -> ECKeyPair { ECKeyPair.generateKeyPair() }

    func store(keyPair: ECKeyPair?, for identity: OWSIdentity, tx: DBWriteTransaction) {
        switch identity {
        case .aci:
            aciKeyPair = keyPair
        case .pni:
            pniKeyPair = keyPair
        }
    }
}

class _PreKey_IdentityKeyMismatchManagerMock: IdentityKeyMismatchManager {
    func recordSuspectedIssueWithPniIdentityKey(tx: DBWriteTransaction) {
    }

    func validateLocalPniIdentityKeyIfNecessary() async {
    }

    var validateIdentityKeyMock: ((_ identity: OWSIdentity) async -> Void)!
    func validateIdentityKey(for identity: OWSIdentity) async {
        await validateIdentityKeyMock!(identity)
    }
}

class _PreKey_DateProviderMock {
    var currentDate: Date = Date()
    func targetDate() -> Date { return currentDate }
}

class _PreKey_APIClientMock: PreKeyTaskAPIClient {
    var currentPreKeyCount: Int?
    var currentPqPreKeyCount: Int?

    var setPreKeysResult: ConsumableMockPromise<Void> = .unset
    var identity: OWSIdentity?
    var signedPreKeyRecord: MunrChatServiceKit.SignedPreKeyRecord?
    var preKeyRecords: [MunrChatServiceKit.PreKeyRecord]?
    var pqLastResortPreKeyRecord: MunrChatServiceKit.KyberPreKeyRecord?
    var pqPreKeyRecords: [MunrChatServiceKit.KyberPreKeyRecord]?
    var auth: ChatServiceAuth?

    func getAvailablePreKeys(for identity: OWSIdentity) async throws -> (ecCount: Int, pqCount: Int) {
        return (currentPreKeyCount!, currentPqPreKeyCount!)
    }

    func registerPreKeys(
        for identity: OWSIdentity,
        signedPreKeyRecord: MunrChatServiceKit.SignedPreKeyRecord?,
        preKeyRecords: [MunrChatServiceKit.PreKeyRecord]?,
        pqLastResortPreKeyRecord: MunrChatServiceKit.KyberPreKeyRecord?,
        pqPreKeyRecords: [MunrChatServiceKit.KyberPreKeyRecord]?,
        auth: ChatServiceAuth
    ) async throws {
        try await setPreKeysResult.consumeIntoPromise().awaitable()

        self.identity = identity
        self.signedPreKeyRecord = signedPreKeyRecord
        self.preKeyRecords = preKeyRecords
        self.pqLastResortPreKeyRecord = pqLastResortPreKeyRecord
        self.pqPreKeyRecords = pqPreKeyRecords
        self.auth = auth
    }
}
