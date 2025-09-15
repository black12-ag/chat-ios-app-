//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import LibMunrChatClient

public enum MediaTierEncryptionType: CaseIterable {
    case outerLayerFullsizeOrThumbnail
    case transitTierThumbnail
}

public struct MediaTierEncryptionMetadata: Equatable {
    let type: MediaTierEncryptionType
    let mediaId: Data
    let hmacKey: Data
    let aesKey: Data

    public var encryptionKey: Data {
        return aesKey + hmacKey
    }
}

public struct MediaRootBackupKey: BackupKeyMaterial {
    public var credentialType: BackupAuthCredentialType { .media }
    public var backupKey: BackupKey

    public init(backupKey: BackupKey) {
        self.backupKey = backupKey
    }

    public func deriveMediaId(_ mediaName: String) throws(BackupKeyMaterialError) -> Data {
        do {
            return try backupKey.deriveMediaId(mediaName)
        } catch {
            throw BackupKeyMaterialError.derivationError(error)
        }
    }

    public func mediaEncryptionMetadata(
        mediaName: String,
        type: MediaTierEncryptionType,
    ) throws(BackupKeyMaterialError) -> MediaTierEncryptionMetadata {
        let mediaId = try self.deriveMediaId(mediaName)
        let keyBytes: Data
        do {
            switch type {
            case .outerLayerFullsizeOrThumbnail:
                keyBytes = try backupKey.deriveMediaEncryptionKey(mediaId)
            case .transitTierThumbnail:
                keyBytes = try backupKey.deriveThumbnailTransitEncryptionKey(mediaId)
            }
        } catch {
            throw BackupKeyMaterialError.derivationError(error)
        }
        owsPrecondition(keyBytes.count >= 64)
        return MediaTierEncryptionMetadata(
            type: type,
            mediaId: mediaId,
            hmacKey: keyBytes.prefix(32),
            aesKey: keyBytes.dropFirst(32).prefix(32),
        )
    }
}
