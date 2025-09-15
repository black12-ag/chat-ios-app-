//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

#if TESTABLE_BUILD

public import LibSignalClient

public class ChangePhoneNumberPniManagerMock: ChangePhoneNumberPniManager {

    private let mockKyberStore: KyberPreKeyStoreImpl

    public init(mockKyberStore: KyberPreKeyStoreImpl) {
        self.mockKyberStore = mockKyberStore
    }

    public func generatePniIdentity(
        forNewE164 newE164: E164,
        localAci: Aci,
        localRecipientUniqueId: String,
        localDeviceId: DeviceId,
        localUserAllDeviceIds: [DeviceId]
    ) async -> ChangePhoneNumberPni.GeneratePniIdentityResult {
        let keyPair = ECKeyPair.generateKeyPair()
        let registrationId = UInt32.random(in: 1...0x3fff)

        let localPqKey1 = self.mockKyberStore.generateLastResortKyberPreKeyForLinkedDevice(signedBy: keyPair)
        let localPqKey2 = self.mockKyberStore.generateLastResortKyberPreKeyForLinkedDevice(signedBy: keyPair)

        return .success(
            parameters: PniDistribution.Parameters.mock(
                pniIdentityKeyPair: keyPair,
                localDeviceId: localDeviceId,
                localDevicePniSignedPreKey: SignedPreKeyStoreImpl.generateSignedPreKey(signedBy: keyPair),
                localDevicePniPqLastResortPreKey: localPqKey1,
                localDevicePniRegistrationId: registrationId
            ),
            pendingState: ChangePhoneNumberPni.PendingState(
                newE164: newE164,
                pniIdentityKeyPair: keyPair,
                localDevicePniSignedPreKeyRecord: SignedPreKeyStoreImpl.generateSignedPreKey(signedBy: keyPair),
                localDevicePniPqLastResortPreKeyRecord: localPqKey2,
                localDevicePniRegistrationId: registrationId
            )
        )
    }

    public func finalizePniIdentity(
        withPendingState pendingState: ChangePhoneNumberPni.PendingState,
        transaction: DBWriteTransaction
    ) throws {
        // do nothing
    }
}

#endif
