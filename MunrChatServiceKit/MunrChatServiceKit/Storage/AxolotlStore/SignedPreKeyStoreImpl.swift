//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import LibMunrChatClient

private let lastPreKeyRotationDate = "lastKeyRotationDate"

public class SignedPreKeyStoreImpl: LibMunrChatClient.SignedPreKeyStore {

    private let identity: OWSIdentity
    private let keyStore: KeyValueStore
    private let metadataStore: KeyValueStore

    public init(for identity: OWSIdentity) {
        self.identity = identity

        switch identity {
        case .aci:
            self.keyStore = KeyValueStore(collection: "TSStorageManagerSignedPreKeyStoreCollection")
            self.metadataStore = KeyValueStore(collection: "TSStorageManagerSignedPreKeyMetadataCollection")
        case .pni:
            self.keyStore = KeyValueStore(collection: "TSStorageManagerPNISignedPreKeyStoreCollection")
            self.metadataStore = KeyValueStore(collection: "TSStorageManagerPNISignedPreKeyMetadataCollection")
        }
    }

    // MARK: - SignedPreKeyStore transactions

    public func loadSignedPreKey(_ signedPreKeyId: Int32, transaction: DBReadTransaction) -> MunrChatServiceKit.SignedPreKeyRecord? {
        keyStore.signedPreKeyRecord(key: keyValueStoreKey(int: Int(signedPreKeyId)), transaction: transaction)
    }

    func storeSignedPreKey(_ signedPreKeyId: Int32, signedPreKeyRecord: MunrChatServiceKit.SignedPreKeyRecord, tx: DBWriteTransaction) {
        keyStore.setSignedPreKeyRecord(signedPreKeyRecord, key: keyValueStoreKey(int: Int(signedPreKeyId)), transaction: tx)
    }

    func removeSignedPreKey(signedPreKeyId: Int32, tx: DBWriteTransaction) {
        Logger.info("Removing signed prekey id: \(signedPreKeyId).")
        keyStore.removeValue(forKey: keyValueStoreKey(int: Int(signedPreKeyId)), transaction: tx)
    }

    private func keyValueStoreKey(int: Int) -> String {
        return NSNumber(value: int).stringValue
    }

    func setReplacedAtToNowIfNil(exceptFor justUploadedSignedPreKey: MunrChatServiceKit.SignedPreKeyRecord, tx: DBWriteTransaction) {
        let exceptForKey = keyValueStoreKey(int: Int(justUploadedSignedPreKey.id))
        keyStore.allKeys(transaction: tx).forEach { key in autoreleasepool {
            if key == exceptForKey {
                return
            }
            let record = keyStore.getObject(key, ofClass: MunrChatServiceKit.SignedPreKeyRecord.self, transaction: tx)
            guard let record, record.replacedAt == nil else {
                return
            }
            record.setReplacedAtToNow()
            storeSignedPreKey(record.id, signedPreKeyRecord: record, tx: tx)
        }}
    }

    func cullSignedPreKeyRecords(gracePeriod: TimeInterval, tx: DBWriteTransaction) {
        keyStore.allKeys(transaction: tx).forEach { key in autoreleasepool {
            let record = keyStore.getObject(key, ofClass: MunrChatServiceKit.SignedPreKeyRecord.self, transaction: tx)
            guard let record else {
                owsFailDebug("Couldn't decode SignedPreKeyRecord.")
                keyStore.removeValue(forKey: key, transaction: tx)
                return
            }
            guard
                let replacedAt = record.replacedAt,
                fabs(replacedAt.timeIntervalSinceNow) > (PreKeyManagerImpl.Constants.maxUnacknowledgedSessionAge + gracePeriod)
            else {
                // Never delete signed prekeys until they're obsolete for N days.
                return
            }
            Logger.info("Deleting signed prekey id: \(record.id), generatedAt: \(record.generatedAt), replacedAt: \(replacedAt)")
            keyStore.removeValue(forKey: key, transaction: tx)
        }}
    }

    // MARK: -

    #if TESTABLE_BUILD

    func count(tx: DBReadTransaction) -> Int {
        return keyStore.allKeys(transaction: tx).count
    }

    #endif

    // MARK: - Prekey rotation tracking

    func setLastSuccessfulRotationDate(_ date: Date, tx: DBWriteTransaction) {
        metadataStore.setDate(date, key: lastPreKeyRotationDate, transaction: tx)
    }

    func getLastSuccessfulRotationDate(tx: DBReadTransaction) -> Date? {
        metadataStore.getDate(lastPreKeyRotationDate, transaction: tx)
    }

    public func removeAll(tx: DBWriteTransaction) {
        Logger.warn("")
        keyStore.removeAll(transaction: tx)
        metadataStore.removeAll(transaction: tx)
    }

    public static func generateSignedPreKey(
        signedBy identityKeyPair: ECKeyPair
    ) -> MunrChatServiceKit.SignedPreKeyRecord {
        let keyPair = ECKeyPair.generateKeyPair()

        // Signed prekey ids must be > 0.
        let preKeyId = Int32.random(in: 1..<Int32.max)

        return SignedPreKeyRecord(
            id: preKeyId,
            keyPair: keyPair,
            signature: identityKeyPair.keyPair.privateKey.generateSignature(
                message: keyPair.keyPair.publicKey.serialize()
            ),
            generatedAt: Date(),
            replacedAt: nil
        )
    }

    enum Error: Swift.Error {
        case noPreKeyWithId(UInt32)
    }

    public func loadSignedPreKey(id: UInt32, context: StoreContext) throws -> LibMunrChatClient.SignedPreKeyRecord {
        guard let preKey = self.loadSignedPreKey(Int32(bitPattern: id), transaction: context.asTransaction) else {
            throw Error.noPreKeyWithId(id)
        }

        return try preKey.asLSCRecord()
    }

    public func storeSignedPreKey(_ record: LibMunrChatClient.SignedPreKeyRecord, id: UInt32, context: StoreContext) throws {
        // This isn't used today. If it's used in the future, `replacedAt` will
        // need to be handled (though it seems likely that nil would be an
        // acceptable default).
        owsAssertDebug(CurrentAppContext().isRunningTests, "This can't be used for updating existing records.")

        let sskRecord = try record.asSSKRecord()

        self.storeSignedPreKey(Int32(bitPattern: id),
                               signedPreKeyRecord: sskRecord,
                               tx: context.asTransaction)
    }
}

extension LibMunrChatClient.SignedPreKeyRecord {
    func asSSKRecord() throws -> MunrChatServiceKit.SignedPreKeyRecord {
        let keyPair = IdentityKeyPair(
            publicKey: try self.publicKey(),
            privateKey: try self.privateKey()
        )

        return MunrChatServiceKit.SignedPreKeyRecord(
            id: Int32(bitPattern: self.id),
            keyPair: ECKeyPair(keyPair),
            signature: self.signature,
            generatedAt: Date(millisecondsSince1970: self.timestamp),
            replacedAt: nil
        )
    }
}

extension MunrChatServiceKit.SignedPreKeyRecord {
    func asLSCRecord() throws -> LibMunrChatClient.SignedPreKeyRecord {
        try LibMunrChatClient.SignedPreKeyRecord(
            id: UInt32(bitPattern: self.id),
            timestamp: self.createdAt?.ows_millisecondsSince1970 ?? 0,
            privateKey: self.keyPair.identityKeyPair.privateKey,
            signature: self.signature
        )
    }
}

extension KeyValueStore {
    fileprivate func signedPreKeyRecord(key: String, transaction: DBReadTransaction) -> MunrChatServiceKit.SignedPreKeyRecord? {
        return getObject(key, ofClass: MunrChatServiceKit.SignedPreKeyRecord.self, transaction: transaction)
    }

    fileprivate func setSignedPreKeyRecord(_ record: MunrChatServiceKit.SignedPreKeyRecord, key: String, transaction: DBWriteTransaction) {
        setObject(record, key: key, transaction: transaction)
    }
}
