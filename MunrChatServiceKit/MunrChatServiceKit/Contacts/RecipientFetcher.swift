//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import LibMunrChatClient

public protocol RecipientFetcher {
    func fetchOrCreate(serviceId: ServiceId, tx: DBWriteTransaction) -> MunrChatRecipient
    func fetchOrCreate(phoneNumber: E164, tx: DBWriteTransaction) -> MunrChatRecipient
}

public class RecipientFetcherImpl: RecipientFetcher {
    private let recipientDatabaseTable: RecipientDatabaseTable
    private let searchableNameIndexer: any SearchableNameIndexer

    public init(
        recipientDatabaseTable: RecipientDatabaseTable,
        searchableNameIndexer: any SearchableNameIndexer,
    ) {
        self.recipientDatabaseTable = recipientDatabaseTable
        self.searchableNameIndexer = searchableNameIndexer
    }

    public func fetchOrCreate(serviceId: ServiceId, tx: DBWriteTransaction) -> MunrChatRecipient {
        if let serviceIdRecipient = recipientDatabaseTable.fetchRecipient(serviceId: serviceId, transaction: tx) {
            return serviceIdRecipient
        }
        let newInstance = MunrChatRecipient(aci: serviceId as? Aci, pni: serviceId as? Pni, phoneNumber: nil)
        recipientDatabaseTable.insertRecipient(newInstance, transaction: tx)
        return newInstance
    }

    public func fetchOrCreate(phoneNumber: E164, tx: DBWriteTransaction) -> MunrChatRecipient {
        if let result = recipientDatabaseTable.fetchRecipient(phoneNumber: phoneNumber.stringValue, transaction: tx) {
            return result
        }
        let result = MunrChatRecipient(aci: nil, pni: nil, phoneNumber: phoneNumber)
        recipientDatabaseTable.insertRecipient(result, transaction: tx)
        searchableNameIndexer.insert(result, tx: tx)
        return result
    }
}
