//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibSignalClient

#if TESTABLE_BUILD

internal class MockPreKeyManager: PreKeyManager {
    func isAppLockedDueToPreKeyUpdateFailures(tx: MunirServiceKit.DBReadTransaction) -> Bool { false }
    func refreshOneTimePreKeysCheckDidSucceed() { }
    func checkPreKeysIfNecessary(tx: MunirServiceKit.DBReadTransaction) { }
    func rotatePreKeysOnUpgradeIfNecessary(for identity: OWSIdentity) async throws { }

    func createPreKeysForRegistration() -> Task<RegistrationPreKeyUploadBundles, Error> {
        let identityKeyPair = ECKeyPair.generateKeyPair()
        return Task {
            .init(
                aci: .init(
                    identity: .aci,
                    identityKeyPair: identityKeyPair,
                    signedPreKey: SignedPreKeyStoreImpl.generateSignedPreKey(signedBy: identityKeyPair),
                    lastResortPreKey: generateLastResortKyberPreKey(signedBy: identityKeyPair)
                ),
                pni: .init(
                    identity: .pni,
                    identityKeyPair: identityKeyPair,
                    signedPreKey: SignedPreKeyStoreImpl.generateSignedPreKey(signedBy: identityKeyPair),
                    lastResortPreKey: generateLastResortKyberPreKey(signedBy: identityKeyPair)
                )
            )
        }
    }

    func createPreKeysForProvisioning(
        aciIdentityKeyPair: ECKeyPair,
        pniIdentityKeyPair: ECKeyPair
    ) -> Task<RegistrationPreKeyUploadBundles, Error> {
        let identityKeyPair = ECKeyPair.generateKeyPair()
        return Task {
            .init(
                aci: .init(
                    identity: .aci,
                    identityKeyPair: identityKeyPair,
                    signedPreKey: SignedPreKeyStoreImpl.generateSignedPreKey(signedBy: identityKeyPair),
                    lastResortPreKey: generateLastResortKyberPreKey(signedBy: identityKeyPair)
                ),
                pni: .init(
                    identity: .pni,
                    identityKeyPair: identityKeyPair,
                    signedPreKey: SignedPreKeyStoreImpl.generateSignedPreKey(signedBy: identityKeyPair),
                    lastResortPreKey: generateLastResortKyberPreKey(signedBy: identityKeyPair)
                )
            )
        }
    }

    public var didFinalizeRegistrationPrekeys = false

    func finalizeRegistrationPreKeys(
        _ bundles: RegistrationPreKeyUploadBundles,
        uploadDidSucceed: Bool
    ) -> Task<Void, Error> {
        didFinalizeRegistrationPrekeys = true
        return Task {}
    }

    func rotateOneTimePreKeysForRegistration(auth: ChatServiceAuth) -> Task<Void, Error> {
        return Task {}
    }

    func rotateSignedPreKeysIfNeeded() -> Task<Void, Error> { Task {} }
    func refreshOneTimePreKeys(forIdentity identity: OWSIdentity, alsoRefreshSignedPreKey shouldRefreshSignedPreKey: Bool) { }

    func generateLastResortKyberPreKey(signedBy signingKeyPair: ECKeyPair) -> MunirServiceKit.KyberPreKeyRecord {

        let keyPair = KEMKeyPair.generate()
        let signature = signingKeyPair.keyPair.privateKey.generateSignature(message: keyPair.publicKey.serialize())

        let record = MunirServiceKit.KyberPreKeyRecord(
            0,
            keyPair: keyPair,
            signature: signature,
            generatedAt: Date(),
            replacedAt: nil,
            isLastResort: true
        )
        return record
    }

    func setIsChangingNumber(_ isChangingNumber: Bool) {
    }
}

#endif
