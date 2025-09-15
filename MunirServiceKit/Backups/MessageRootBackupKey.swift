//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import LibSignalClient

public struct MessageRootBackupKey: BackupKeyMaterial {
    public var credentialType: BackupAuthCredentialType { .messages }
    public let backupKey: BackupKey
    public let backupId: Data

    public let aci: Aci

    public init(accountEntropyPool: AccountEntropyPool, aci: Aci) throws(BackupKeyMaterialError) {
        do {
            let backupKey = try LibSignalClient.AccountEntropyPool.deriveBackupKey(accountEntropyPool.rawData)
            self.init(backupKey: backupKey, aci: aci)
        } catch {
            throw BackupKeyMaterialError.derivationError(error)
        }
    }

    init(backupKey: BackupKey, aci: Aci) {
        self.backupKey = backupKey
        self.backupId = backupKey.deriveBackupId(aci: aci)
        self.aci = aci
    }
}
