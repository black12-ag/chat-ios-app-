//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import GRDB

extension Attachment {
    public struct Record: Codable, MutablePersistableRecord, FetchableRecord, Equatable, UInt64SafeRecord {

        public typealias IDType = Int64

        var sqliteId: IDType?
        let blurHash: String?
        var sha256ContentHash: Data?
        let encryptedByteCount: UInt32?
        let unencryptedByteCount: UInt32?
        let mimeType: String
        let encryptionKey: Data
        let digestSHA256Ciphertext: Data?
        let contentType: UInt32?
        let latestTransitCdnNumber: UInt32?
        let latestTransitCdnKey: String?
        let latestTransitUploadTimestamp: UInt64?
        let latestTransitEncryptionKey: Data?
        let latestTransitUnencryptedByteCount: UInt32?
        let latestTransitDigestSHA256Ciphertext: Data?
        let latestTransitLastDownloadAttemptTimestamp: UInt64?
        let mediaName: String?
        let mediaTierCdnNumber: UInt32?
        let mediaTierUnencryptedByteCount: UInt32?
        let mediaTierUploadEra: String?
        let lastMediaTierDownloadAttemptTimestamp: UInt64?
        let thumbnailCdnNumber: UInt32?
        let thumbnailUploadEra: String?
        let lastThumbnailDownloadAttemptTimestamp: UInt64?
        let localRelativeFilePath: String?
        let localRelativeFilePathThumbnail: String?
        let cachedAudioDurationSeconds: Double?
        let cachedMediaHeightPixels: UInt32?
        let cachedMediaWidthPixels: UInt32?
        let cachedVideoDurationSeconds: Double?
        let audioWaveformRelativeFilePath: String?
        let videoStillFrameRelativeFilePath: String?
        let originalAttachmentIdForQuotedReply: Int64?
        let mediaTierIncrementalMac: Data?
        let mediaTierIncrementalMacChunkSize: UInt32?
        let latestTransitTierIncrementalMac: Data?
        let latestTransitTierIncrementalMacChunkSize: UInt32?
        let lastFullscreenViewTimestamp: UInt64?
        let originalTransitCdnNumber: UInt32?
        let originalTransitCdnKey: String?
        let originalTransitUploadTimestamp: UInt64?
        let originalTransitUnencryptedByteCount: UInt32?
        let originalTransitDigestSHA256Ciphertext: Data?
        let originalTransitTierIncrementalMac: Data?
        let originalTransitTierIncrementalMacChunkSize: UInt32?

        public var allFilesRelativePaths: [String] {
            return [
                localRelativeFilePath,
                localRelativeFilePathThumbnail,
                videoStillFrameRelativeFilePath,
                audioWaveformRelativeFilePath
            ].compacted()
        }

        // MARK: - Coding Keys

        public enum CodingKeys: String, CodingKey {
            case sqliteId = "id"
            case blurHash
            case mimeType
            case sha256ContentHash
            case encryptedByteCount
            case unencryptedByteCount
            case contentType
            case encryptionKey
            case digestSHA256Ciphertext
            case latestTransitCdnNumber = "transitCdnNumber"
            case latestTransitCdnKey = "transitCdnKey"
            case latestTransitUploadTimestamp = "transitUploadTimestamp"
            case latestTransitEncryptionKey = "transitEncryptionKey"
            case latestTransitUnencryptedByteCount = "transitUnencryptedByteCount"
            case latestTransitDigestSHA256Ciphertext = "transitDigestSHA256Ciphertext"
            case latestTransitLastDownloadAttemptTimestamp = "lastTransitDownloadAttemptTimestamp"
            case mediaName
            case mediaTierCdnNumber
            case mediaTierUnencryptedByteCount
            case mediaTierUploadEra
            case lastMediaTierDownloadAttemptTimestamp
            case thumbnailCdnNumber
            case thumbnailUploadEra
            case lastThumbnailDownloadAttemptTimestamp
            case localRelativeFilePath
            case localRelativeFilePathThumbnail
            case cachedAudioDurationSeconds
            case cachedMediaHeightPixels
            case cachedMediaWidthPixels
            case cachedVideoDurationSeconds
            case audioWaveformRelativeFilePath
            case videoStillFrameRelativeFilePath
            case originalAttachmentIdForQuotedReply
            case mediaTierIncrementalMac
            case mediaTierIncrementalMacChunkSize
            case latestTransitTierIncrementalMac = "transitTierIncrementalMac"
            case latestTransitTierIncrementalMacChunkSize = "transitTierIncrementalMacChunkSize"
            case lastFullscreenViewTimestamp
            case originalTransitCdnNumber
            case originalTransitCdnKey
            case originalTransitUploadTimestamp
            case originalTransitUnencryptedByteCount
            case originalTransitDigestSHA256Ciphertext
            case originalTransitTierIncrementalMac
            case originalTransitTierIncrementalMacChunkSize
        }

        // MARK: - UInt64SafeRecord

        public static var uint64Fields: [KeyPath<Attachment.Record, UInt64>] { [] }

        public static var uint64OptionalFields: [KeyPath<Self, UInt64?>] {
            return [
                \.latestTransitUploadTimestamp,
                \.latestTransitLastDownloadAttemptTimestamp,
                \.lastMediaTierDownloadAttemptTimestamp,
                \.lastThumbnailDownloadAttemptTimestamp,
                \.lastFullscreenViewTimestamp,
                \.originalTransitUploadTimestamp,
            ]
        }

        // MARK: - MutablePersistableRecord

        public static let databaseTableName: String = "Attachment"

        public mutating func didInsert(with rowID: Int64, for column: String?) {
            self.sqliteId = rowID
        }

        // MARK: - Initializers

        internal init(
            sqliteId: IDType? = nil,
            blurHash: String?,
            sha256ContentHash: Data?,
            encryptedByteCount: UInt32?,
            unencryptedByteCount: UInt32?,
            mimeType: String,
            encryptionKey: Data,
            digestSHA256Ciphertext: Data?,
            contentType: UInt32?,
            latestTransitCdnNumber: UInt32?,
            latestTransitCdnKey: String?,
            latestTransitUploadTimestamp: UInt64?,
            latestTransitEncryptionKey: Data?,
            latestTransitUnencryptedByteCount: UInt32?,
            latestTransitDigestSHA256Ciphertext: Data?,
            latestTransitLastDownloadAttemptTimestamp: UInt64?,
            mediaName: String?,
            mediaTierCdnNumber: UInt32?,
            mediaTierUnencryptedByteCount: UInt32?,
            mediaTierUploadEra: String?,
            lastMediaTierDownloadAttemptTimestamp: UInt64?,
            thumbnailCdnNumber: UInt32?,
            thumbnailUploadEra: String?,
            lastThumbnailDownloadAttemptTimestamp: UInt64?,
            localRelativeFilePath: String?,
            localRelativeFilePathThumbnail: String?,
            cachedAudioDurationSeconds: Double?,
            cachedMediaHeightPixels: UInt32?,
            cachedMediaWidthPixels: UInt32?,
            cachedVideoDurationSeconds: Double?,
            audioWaveformRelativeFilePath: String?,
            videoStillFrameRelativeFilePath: String?,
            originalAttachmentIdForQuotedReply: Int64?,
            mediaTierIncrementalMac: Data?,
            mediaTierIncrementalMacChunkSize: UInt32?,
            latestTransitTierIncrementalMac: Data?,
            latestTransitTierIncrementalMacChunkSize: UInt32?,
            lastFullscreenViewTimestamp: UInt64?,
            originalTransitCdnNumber: UInt32?,
            originalTransitCdnKey: String?,
            originalTransitUploadTimestamp: UInt64?,
            originalTransitUnencryptedByteCount: UInt32?,
            originalTransitDigestSHA256Ciphertext: Data?,
            originalTransitTierIncrementalMac: Data?,
            originalTransitTierIncrementalMacChunkSize: UInt32?,
        ) {
            self.sqliteId = sqliteId
            self.blurHash = blurHash
            self.sha256ContentHash = sha256ContentHash
            self.encryptedByteCount = encryptedByteCount
            self.unencryptedByteCount = unencryptedByteCount
            self.mimeType = mimeType
            self.encryptionKey = encryptionKey
            self.digestSHA256Ciphertext = digestSHA256Ciphertext
            self.contentType = contentType
            self.latestTransitCdnNumber = latestTransitCdnNumber
            self.latestTransitCdnKey = latestTransitCdnKey
            self.latestTransitUploadTimestamp = latestTransitUploadTimestamp
            self.latestTransitEncryptionKey = latestTransitEncryptionKey
            self.latestTransitUnencryptedByteCount = latestTransitUnencryptedByteCount
            self.latestTransitDigestSHA256Ciphertext = latestTransitDigestSHA256Ciphertext
            self.latestTransitLastDownloadAttemptTimestamp = latestTransitLastDownloadAttemptTimestamp
            self.mediaName = mediaName
            self.mediaTierCdnNumber = mediaTierCdnNumber
            self.mediaTierUnencryptedByteCount = mediaTierUnencryptedByteCount
            self.mediaTierUploadEra = mediaTierUploadEra
            self.lastMediaTierDownloadAttemptTimestamp = lastMediaTierDownloadAttemptTimestamp
            self.thumbnailCdnNumber = thumbnailCdnNumber
            self.thumbnailUploadEra = thumbnailUploadEra
            self.lastThumbnailDownloadAttemptTimestamp = lastThumbnailDownloadAttemptTimestamp
            self.localRelativeFilePath = localRelativeFilePath
            self.localRelativeFilePathThumbnail = localRelativeFilePathThumbnail
            self.cachedAudioDurationSeconds = cachedAudioDurationSeconds
            self.cachedMediaHeightPixels = cachedMediaHeightPixels
            self.cachedMediaWidthPixels = cachedMediaWidthPixels
            self.cachedVideoDurationSeconds = cachedVideoDurationSeconds
            self.audioWaveformRelativeFilePath = audioWaveformRelativeFilePath
            self.videoStillFrameRelativeFilePath = videoStillFrameRelativeFilePath
            self.originalAttachmentIdForQuotedReply = originalAttachmentIdForQuotedReply
            self.mediaTierIncrementalMac = mediaTierIncrementalMac
            self.mediaTierIncrementalMacChunkSize = mediaTierIncrementalMacChunkSize
            self.latestTransitTierIncrementalMac = latestTransitTierIncrementalMac
            self.latestTransitTierIncrementalMacChunkSize = latestTransitTierIncrementalMacChunkSize
            self.lastFullscreenViewTimestamp = lastFullscreenViewTimestamp
            self.originalTransitCdnNumber = originalTransitCdnNumber
            self.originalTransitCdnKey = originalTransitCdnKey
            self.originalTransitUploadTimestamp = originalTransitUploadTimestamp
            self.originalTransitUnencryptedByteCount = originalTransitUnencryptedByteCount
            self.originalTransitDigestSHA256Ciphertext = originalTransitDigestSHA256Ciphertext
            self.originalTransitTierIncrementalMac = originalTransitTierIncrementalMac
            self.originalTransitTierIncrementalMacChunkSize = originalTransitTierIncrementalMacChunkSize
        }

        internal init(attachment: Attachment) {
            self.init(
                sqliteId: attachment.id,
                blurHash: attachment.blurHash,
                mimeType: attachment.mimeType,
                encryptionKey: attachment.encryptionKey,
                sha256ContentHash: attachment.sha256ContentHash,
                mediaName: attachment.mediaName,
                localRelativeFilePathThumbnail: attachment.localRelativeFilePathThumbnail,
                streamInfo: attachment.streamInfo,
                latestTransitTierInfo: attachment.latestTransitTierInfo,
                originalTransitTierInfo: attachment.originalTransitTierInfo,
                mediaTierInfo: attachment.mediaTierInfo,
                thumbnailMediaTierInfo: attachment.thumbnailMediaTierInfo,
                originalAttachmentIdForQuotedReply: attachment.originalAttachmentIdForQuotedReply,
                lastFullscreenViewTimestamp: attachment.lastFullscreenViewTimestamp,
            )
        }

        internal init(params: Attachment.ConstructionParams) {
            self.init(
                optionalSqliteId: nil,
                blurHash: params.blurHash,
                mimeType: params.mimeType,
                encryptionKey: params.encryptionKey,
                sha256ContentHash: params.sha256ContentHash,
                mediaName: params.mediaName,
                localRelativeFilePathThumbnail: params.localRelativeFilePathThumbnail,
                streamInfo: params.streamInfo,
                latestTransitTierInfo: params.latestTransitTierInfo,
                originalTransitTierInfo: params.originalTransitTierInfo,
                mediaTierInfo: params.mediaTierInfo,
                thumbnailMediaTierInfo: params.thumbnailMediaTierInfo,
                originalAttachmentIdForQuotedReply: params.originalAttachmentIdForQuotedReply,
                lastFullscreenViewTimestamp: params.lastFullscreenViewTimestamp,
            )
        }

        internal init(
            sqliteId: IDType,
            blurHash: String?,
            mimeType: String,
            encryptionKey: Data,
            sha256ContentHash: Data?,
            mediaName: String?,
            localRelativeFilePathThumbnail: String?,
            streamInfo: Attachment.StreamInfo?,
            latestTransitTierInfo: Attachment.TransitTierInfo?,
            originalTransitTierInfo: Attachment.TransitTierInfo?,
            mediaTierInfo: Attachment.MediaTierInfo?,
            thumbnailMediaTierInfo: Attachment.ThumbnailMediaTierInfo?,
            originalAttachmentIdForQuotedReply: Int64?,
            lastFullscreenViewTimestamp: UInt64?,
        ) {
            self.init(
                optionalSqliteId: sqliteId,
                blurHash: blurHash,
                mimeType: mimeType,
                encryptionKey: encryptionKey,
                sha256ContentHash: sha256ContentHash,
                mediaName: mediaName,
                localRelativeFilePathThumbnail: localRelativeFilePathThumbnail,
                streamInfo: streamInfo,
                latestTransitTierInfo: latestTransitTierInfo,
                originalTransitTierInfo: originalTransitTierInfo,
                mediaTierInfo: mediaTierInfo,
                thumbnailMediaTierInfo: thumbnailMediaTierInfo,
                originalAttachmentIdForQuotedReply: originalAttachmentIdForQuotedReply,
                lastFullscreenViewTimestamp: lastFullscreenViewTimestamp,
            )
        }

        // Private as we want to be deliberate around when sqlite id is not provided.
        private init(
            optionalSqliteId: IDType?,
            blurHash: String?,
            mimeType: String,
            encryptionKey: Data,
            sha256ContentHash: Data?,
            mediaName: String?,
            localRelativeFilePathThumbnail: String?,
            streamInfo: Attachment.StreamInfo?,
            latestTransitTierInfo: Attachment.TransitTierInfo?,
            originalTransitTierInfo: Attachment.TransitTierInfo?,
            mediaTierInfo: Attachment.MediaTierInfo?,
            thumbnailMediaTierInfo: Attachment.ThumbnailMediaTierInfo?,
            originalAttachmentIdForQuotedReply: Int64?,
            lastFullscreenViewTimestamp: UInt64?,
        ) {
            self.sqliteId = optionalSqliteId
            self.blurHash = blurHash
            self.sha256ContentHash = sha256ContentHash
            self.encryptedByteCount = streamInfo?.encryptedByteCount
            self.unencryptedByteCount = streamInfo?.unencryptedByteCount
            self.mimeType = mimeType
            self.encryptionKey = encryptionKey
            self.digestSHA256Ciphertext = streamInfo?.digestSHA256Ciphertext
            self.contentType = (streamInfo?.contentType.raw.rawValue).map { UInt32($0) }
            self.latestTransitCdnNumber = latestTransitTierInfo?.cdnNumber
            self.latestTransitCdnKey = latestTransitTierInfo?.cdnKey
            self.latestTransitUploadTimestamp = latestTransitTierInfo?.uploadTimestamp
            self.latestTransitEncryptionKey = latestTransitTierInfo?.encryptionKey
            self.latestTransitUnencryptedByteCount = latestTransitTierInfo?.unencryptedByteCount
            switch latestTransitTierInfo?.integrityCheck {
            case .digestSHA256Ciphertext(let data):
                self.latestTransitDigestSHA256Ciphertext = data
            case nil, .sha256ContentHash:
                self.latestTransitDigestSHA256Ciphertext = nil
            }
            self.latestTransitTierIncrementalMac = latestTransitTierInfo?.incrementalMacInfo?.mac
            self.latestTransitTierIncrementalMacChunkSize = latestTransitTierInfo?.incrementalMacInfo?.chunkSize
            self.latestTransitLastDownloadAttemptTimestamp = latestTransitTierInfo?.lastDownloadAttemptTimestamp

            self.originalTransitCdnNumber = originalTransitTierInfo?.cdnNumber
            self.originalTransitCdnKey = originalTransitTierInfo?.cdnKey
            self.originalTransitUploadTimestamp = originalTransitTierInfo?.uploadTimestamp
            self.originalTransitUnencryptedByteCount = originalTransitTierInfo?.unencryptedByteCount
            switch originalTransitTierInfo?.integrityCheck {
            case .digestSHA256Ciphertext(let data):
                self.originalTransitDigestSHA256Ciphertext = data
            case nil, .sha256ContentHash:
                self.originalTransitDigestSHA256Ciphertext = nil
            }
            self.originalTransitTierIncrementalMac = originalTransitTierInfo?.incrementalMacInfo?.mac
            self.originalTransitTierIncrementalMacChunkSize = originalTransitTierInfo?.incrementalMacInfo?.chunkSize

            self.mediaName = mediaName
            self.mediaTierCdnNumber = mediaTierInfo?.cdnNumber
            self.mediaTierUnencryptedByteCount = mediaTierInfo?.unencryptedByteCount
            self.mediaTierIncrementalMac = mediaTierInfo?.incrementalMacInfo?.mac
            self.mediaTierIncrementalMacChunkSize = mediaTierInfo?.incrementalMacInfo?.chunkSize
            self.mediaTierUploadEra = mediaTierInfo?.uploadEra
            self.lastMediaTierDownloadAttemptTimestamp = mediaTierInfo?.lastDownloadAttemptTimestamp
            self.thumbnailCdnNumber = thumbnailMediaTierInfo?.cdnNumber
            self.thumbnailUploadEra = thumbnailMediaTierInfo?.uploadEra
            self.lastThumbnailDownloadAttemptTimestamp = thumbnailMediaTierInfo?.lastDownloadAttemptTimestamp
            self.localRelativeFilePath = streamInfo?.localRelativeFilePath
            self.localRelativeFilePathThumbnail = localRelativeFilePathThumbnail
            self.originalAttachmentIdForQuotedReply = originalAttachmentIdForQuotedReply
            self.lastFullscreenViewTimestamp = lastFullscreenViewTimestamp

            let cachedAudioDurationSeconds: TimeInterval?
            let cachedMediaSizePixels: CGSize?
            let cachedVideoDurationSeconds: TimeInterval?
            let audioWaveformRelativeFilePath: String?
            let videoStillFrameRelativeFilePath: String?

            switch streamInfo?.contentType {
            case .invalid, .file, nil:
                cachedAudioDurationSeconds = nil
                cachedMediaSizePixels = nil
                cachedVideoDurationSeconds = nil
                audioWaveformRelativeFilePath = nil
                videoStillFrameRelativeFilePath = nil
            case .image(let pixelSize):
                cachedAudioDurationSeconds = nil
                cachedMediaSizePixels = pixelSize
                cachedVideoDurationSeconds = nil
                audioWaveformRelativeFilePath = nil
                videoStillFrameRelativeFilePath = nil
            case .video(let duration, let pixelSize, let stillFrameRelativeFilePath):
                cachedAudioDurationSeconds = nil
                cachedMediaSizePixels = pixelSize
                cachedVideoDurationSeconds = duration
                audioWaveformRelativeFilePath = nil
                videoStillFrameRelativeFilePath = stillFrameRelativeFilePath
            case .animatedImage(let pixelSize):
                cachedAudioDurationSeconds = nil
                cachedMediaSizePixels = pixelSize
                cachedVideoDurationSeconds = nil
                audioWaveformRelativeFilePath = nil
                videoStillFrameRelativeFilePath = nil
            case .audio(let duration, let waveformRelativeFilePath):
                cachedAudioDurationSeconds = duration
                cachedMediaSizePixels = nil
                cachedVideoDurationSeconds = nil
                audioWaveformRelativeFilePath = waveformRelativeFilePath
                videoStillFrameRelativeFilePath = nil
            }

            self.cachedAudioDurationSeconds = cachedAudioDurationSeconds
            self.cachedMediaHeightPixels = cachedMediaSizePixels.map { UInt32(exactly: $0.height.rounded()) } ?? nil
            self.cachedMediaWidthPixels = cachedMediaSizePixels.map { UInt32(exactly: $0.width.rounded()) } ?? nil
            self.cachedVideoDurationSeconds = cachedVideoDurationSeconds
            self.audioWaveformRelativeFilePath = audioWaveformRelativeFilePath
            self.videoStillFrameRelativeFilePath = videoStillFrameRelativeFilePath
        }
    }
}
