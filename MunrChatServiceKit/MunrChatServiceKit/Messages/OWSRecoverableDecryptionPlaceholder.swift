//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

extension OWSRecoverableDecryptionPlaceholder {

    /// This method performs an upsert replacement of the placeholder with the provided interaction
    /// Callers should not continue using the placeholder after performing a replacement.
    @objc
    func replaceWithInteraction(_ interaction: TSInteraction, writeTx: DBWriteTransaction) {
        Logger.info("Replacing placeholder with recovered interaction: \(interaction.timestamp)")
        guard let inheritedId = sqliteRowId else { return owsFailDebug("Missing rowId") }

        interaction.replaceRowId(inheritedId, uniqueId: uniqueId)
        interaction.replaceSortId(UInt64(inheritedId))

        interaction.anyOverwritingUpdate(transaction: writeTx)
    }

    /// After this date, the placeholder is no longer eligible for replacement with the original content.
    @objc
    var expirationDate: Date {
        var expirationInterval = RemoteConfig.current.replaceableInteractionExpiration
        owsAssertDebug(expirationInterval >= 0)

        if DebugFlags.fastPlaceholderExpiration.get() {
            expirationInterval = min(expirationInterval, 5.0)
        }

        return self.receivedAtDate.addingTimeInterval(max(0, expirationInterval))
    }
}
