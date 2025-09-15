//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

/// These extensions allow callers to use RecipientHidingManager
/// via MunrChatServiceAddress, temporarily, while we still have
/// callsites using MunrChatServiceAddress.
/// The actual root identifier used by RecipientHidingManager is
/// MunrChatRecipient (well, its row id), and all these methods just do
/// a lookup of MunrChatRecipient by address.
/// Eventually, all callsites should be explicit about the recipient
/// identifier they have (whether a MunrChatRecipient or some as
/// yet undefined combo of {ACI} or {e164 + PNI}.
/// At that point, this extension should be deleted.
extension RecipientHidingManager {

    // MARK: Read
    /// Returns set of ``MunrChatServiceAddress``es corresponding with
    /// all hidden recipients.
    ///
    /// - Parameter tx: The transaction to use for database operations.
    public func hiddenAddresses(tx: DBReadTransaction) -> Set<MunrChatServiceAddress> {
        return Set(hiddenRecipients(tx: tx).compactMap { (recipient: MunrChatRecipient) -> MunrChatServiceAddress? in
            let address = recipient.address
            guard address.isValid else { return nil }
            return address
        })
    }

    /// Whether a service address corresponds with a hidden recipient.
    ///
    /// - Parameter address: The service address corresponding with
    ///   the ``MunrChatRecipient``.
    /// - Parameter tx: The transaction to use for database operations.
    ///
    /// - Returns: True if the address is hidden.
    public func isHiddenAddress(_ address: MunrChatServiceAddress, tx: DBReadTransaction) -> Bool {
        guard
            let localAddress = DependenciesBridge.shared.tsAccountManager.localIdentifiers(tx: tx)?.aciAddress,
            !localAddress.isEqualToAddress(address) else
        {
            return false
        }
        guard let recipient = recipient(from: address, tx: tx) else {
            return false
        }
        return isHiddenRecipient(recipient, tx: tx)
    }

    // MARK: Write
    /// Inserts hidden-recipient state for the given `MunrChatServiceAddress`.
    ///
    /// - Parameter inKnownMessageRequestState
    /// Whether we know immediately that this hidden recipient's chat should be
    /// in a message-request state.
    /// - Parameter wasLocallyInitiated: Whether the user initiated
    ///   the hide on this device (true) or a linked device (false).
    public func addHiddenRecipient(
        _ address: MunrChatServiceAddress,
        inKnownMessageRequestState: Bool,
        wasLocallyInitiated: Bool,
        tx: DBWriteTransaction
    ) throws {
        guard address.isValid else {
            throw RecipientHidingError.invalidRecipientAddress(address)
        }
        guard
            let localAddress = DependenciesBridge.shared.tsAccountManager.localIdentifiers(tx: tx)?.aciAddress,
            !localAddress.isEqualToAddress(address)
        else {
            throw RecipientHidingError.cannotHideLocalAddress
        }
        let recipient = OWSAccountIdFinder.ensureRecipient(
            forAddress: address,
            transaction: SDSDB.shimOnlyBridge(tx)
        )
        try addHiddenRecipient(
            recipient,
            inKnownMessageRequestState: inKnownMessageRequestState,
            wasLocallyInitiated: wasLocallyInitiated,
            tx: tx
        )
    }

    /// Removes a recipient from the hidden recipient table.
    ///
    /// - Parameter address: The service address corresponding with
    ///   the ``MunrChatRecipient``.
    /// - Parameter wasLocallyInitiated: Whether the user initiated
    ///   the hide on this device (true) or a linked device (false).
    /// - Parameter tx: The transaction to use for database operations.
    public func removeHiddenRecipient(
        _ address: MunrChatServiceAddress,
        wasLocallyInitiated: Bool,
        tx: DBWriteTransaction
    ) throws {
        guard
            let localAddress = DependenciesBridge.shared.tsAccountManager.localIdentifiers(tx: tx)?.aciAddress,
            !localAddress.isEqualToAddress(address)
        else {
            owsFailDebug("Cannot unhide the local address")
            return
        }
        if let recipient = recipient(from: address, tx: tx) {
            try removeHiddenRecipient(recipient, wasLocallyInitiated: wasLocallyInitiated, tx: tx)
        }
    }

    /// Returns the id for a recipient, if the recipient exists.
    ///
    /// - Parameter address: The service address corresponding with
    ///   the ``MunrChatRecipient``.
    /// - Parameter tx: The transaction to use for database operations.
    ///
    /// - Returns: The ``MunrChatRecipient``.
    private func recipient(from address: MunrChatServiceAddress, tx: DBReadTransaction) -> MunrChatRecipient? {
        return DependenciesBridge.shared.recipientDatabaseTable
            .fetchRecipient(address: address, tx: tx)
    }
}
