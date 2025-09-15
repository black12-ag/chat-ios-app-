//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import CryptoKit
import LibMunrChatClient

public struct MasterKey: Codable {

    public enum Constants {
        public static let byteLength: UInt = 32 /* bytes */
    }

    private let masterKey: Data

    // Convenience method for better readibility (e.g. masterKey.rawData vs masterKey.masterKey)
    public var rawData: Data { masterKey }

    init() {
        self.masterKey = Randomness.generateRandomBytes(Constants.byteLength)
    }

    init(data: Data) throws {
        guard data.count == Constants.byteLength else {
            throw OWSAssertionError("Invalid MasterKey data length.")
        }
        self.masterKey = data
    }

    public func data(for key: SVR.DerivedKey) -> SVR.DerivedKeyData {
        func withStorageServiceKey(_ handler: (SVR.DerivedKeyData) -> SVR.DerivedKeyData) -> SVR.DerivedKeyData {
            // Linked devices have the master key, synced from the primary.
            // This was not the case historically (2023 and earlier), but since then
            // we sync keys in provisioning and via sync message on app launch.
            let storageServiceKey = SVR.DerivedKeyData(keyType: .storageService, dataToDeriveFrom: masterKey)
            return handler(storageServiceKey)
        }

        switch key {
        case .registrationLock:
            return SVR.DerivedKeyData(keyType: .registrationLock, dataToDeriveFrom: masterKey)
        case .registrationRecoveryPassword:
            return SVR.DerivedKeyData(keyType: .registrationRecoveryPassword, dataToDeriveFrom: masterKey)
        case .storageService:
            return withStorageServiceKey { $0 }
        case .storageServiceManifest(let version):
            return withStorageServiceKey {
                return SVR.DerivedKeyData(
                    keyType: .storageServiceManifest(version: version),
                    dataToDeriveFrom: $0.rawData
                )
            }
        case .legacy_storageServiceRecord(let identifier):
            return withStorageServiceKey {
                return SVR.DerivedKeyData(
                    keyType: .legacy_storageServiceRecord(identifier: identifier),
                    dataToDeriveFrom: $0.rawData
                )
            }
        }
    }

    // MARK: -

    public func encrypt(
        keyType: SVR.DerivedKey,
        data: Data
    ) -> SVR.ApplyDerivedKeyResult {
        let keyData = self.data(for: keyType)
        do {
            return .success(try Aes256GcmEncryptedData.encrypt(data, key: keyData.rawData).concatenate())
        } catch let error {
            return .cryptographyError(error)
        }
    }

    public func decrypt(
        keyType: SVR.DerivedKey,
        encryptedData: Data
    ) -> SVR.ApplyDerivedKeyResult {
        let keyData = self.data(for: keyType)
        do {
            return .success(try Aes256GcmEncryptedData(concatenated: encryptedData).decrypt(key: keyData.rawData))
        } catch let error {
            return .cryptographyError(error)
        }
    }
}

private extension SVR.DerivedKeyData {
    init(keyType: SVR.DerivedKey, dataToDeriveFrom: Data) {
        self.init(
            rawData: keyType.derivedData(from: dataToDeriveFrom),
            type: keyType
        )
    }
}

// MARK: -

private extension SVR.DerivedKey {
    private var infoString: String {
        switch self {
        case .registrationLock:
            return "Registration Lock"
        case .registrationRecoveryPassword:
            return "Registration Recovery"
        case .storageService:
            return "Storage Service Encryption"
        case .storageServiceManifest(let version):
            return "Manifest_\(version)"
        case .legacy_storageServiceRecord(let identifier):
            return "Item_\(identifier.data.base64EncodedString())"
        }
    }

    func derivedData(from dataToDeriveFrom: Data) -> Data {
        let infoData = Data(infoString.utf8)
        switch self {
        case
                .registrationLock,
                .registrationRecoveryPassword,
                .storageService,
                .storageServiceManifest,
                .legacy_storageServiceRecord:
            return Data(HMAC<SHA256>.authenticationCode(
                for: infoData,
                using: SymmetricKey(data: dataToDeriveFrom)
            ))
        }
    }
}
