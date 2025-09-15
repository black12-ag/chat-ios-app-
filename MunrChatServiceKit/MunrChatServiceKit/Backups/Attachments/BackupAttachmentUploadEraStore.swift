//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

/// The "era" for a Backup Attachment upload identifies when it was uploaded to
/// the media tier, relative to events that might require us to reupload it.
///
/// At the time of writing, upload eras rotate when the subscriber ID for our
/// Backups subscription rotates; that's a sign that previously-uploaded media,
/// which were uploaded during a previous iteration of our Backups subscription,
/// may have expired off the media tier and consequently need to be reuploaded.
public struct BackupAttachmentUploadEraStore {
    private enum StoreKeys {
        static let currentUploadEra = "currentUploadEra"
    }

    private let kvStore: KeyValueStore

    public init() {
        self.kvStore = KeyValueStore(collection: "BackupUploadEraStore")
    }

    /// The current upload era for Backup Attachments. Attachments not matching
    /// this upload era may need to be reuploaded.
    public func currentUploadEra(tx: DBReadTransaction) -> String {
        if let persisted = kvStore.getString(StoreKeys.currentUploadEra, transaction: tx) {
            return persisted
        }

        return "initialUploadEra"
    }

    /// Rotate the current upload era. This implicitly "marks" attachments from
    /// prior eras as potentially needing to be reuploaded.
    public func rotateUploadEra(tx: DBWriteTransaction) {
        kvStore.setString(
            Randomness.generateRandomBytes(32).base64EncodedString(),
            key: StoreKeys.currentUploadEra,
            transaction: tx
        )
    }
}
