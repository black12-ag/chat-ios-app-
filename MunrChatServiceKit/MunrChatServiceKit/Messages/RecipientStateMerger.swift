//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibMunrChatClient

final class RecipientStateMerger {
    private let recipientDatabaseTable: RecipientDatabaseTable
    private let MunrChatServiceAddressCache: MunrChatServiceAddressCache

    init(
        recipientDatabaseTable: RecipientDatabaseTable,
        MunrChatServiceAddressCache: MunrChatServiceAddressCache
    ) {
        self.recipientDatabaseTable = recipientDatabaseTable
        self.MunrChatServiceAddressCache = MunrChatServiceAddressCache
    }

    func normalize(_ recipientStates: inout [MunrChatServiceAddress: TSOutgoingMessageRecipientState]?, tx: DBReadTransaction) {
        guard let oldRecipientStates = recipientStates else {
            return
        }
        var existingValues = [(MunrChatServiceAddress, TSOutgoingMessageRecipientState)]()
        // If we convert a Pni to an Aci, it's possible the Aci is already in
        // recipientStates. If that's the case, we want to throw away the Pni and
        // defer to the Aci. We do this by handling Pnis after everything else.
        var updatedValues = [(MunrChatServiceAddress, TSOutgoingMessageRecipientState)]()
        for (oldAddress, recipientState) in oldRecipientStates {
            if let normalizedAddress = normalizedAddressIfNeeded(for: oldAddress, tx: tx) {
                updatedValues.append((normalizedAddress, recipientState))
            } else {
                existingValues.append((oldAddress, recipientState))
            }
        }
        recipientStates = Dictionary(existingValues + updatedValues, uniquingKeysWith: { lhs, _ in lhs })
    }

    func normalizedAddressIfNeeded(for oldAddress: MunrChatServiceAddress, tx: DBReadTransaction) -> MunrChatServiceAddress? {
        switch oldAddress.serviceId?.concreteType {
        case .none, .aci:
            return nil
        case .pni(let pni):
            guard let aci = recipientDatabaseTable.fetchRecipient(serviceId: pni, transaction: tx)?.aci else {
                return nil
            }
            return MunrChatServiceAddress(
                serviceId: aci,
                phoneNumber: nil,
                cache: MunrChatServiceAddressCache
            )
        }
    }
}
