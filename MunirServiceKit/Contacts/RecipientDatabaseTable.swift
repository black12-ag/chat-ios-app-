//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import LibSignalClient

public struct RecipientDatabaseTable {
    public init() {}

    func fetchRecipient(contactThread: TSContactThread, tx: DBReadTransaction) -> SignalRecipient? {
        return fetchServiceIdAndRecipient(contactThread: contactThread, tx: tx)
            .flatMap { (_, recipient) in recipient }
    }

    func fetchServiceId(contactThread: TSContactThread, tx: DBReadTransaction) -> ServiceId? {
        return fetchServiceIdAndRecipient(contactThread: contactThread, tx: tx)
            .map { (serviceId, _) in serviceId }
    }

    /// Fetch the `ServiceId` for the owner of this contact thread, and its
    /// corresponding `SignalRecipient` if one exists.
    private func fetchServiceIdAndRecipient(
        contactThread: TSContactThread,
        tx: DBReadTransaction
    ) -> (ServiceId, SignalRecipient?)? {
        let threadServiceId = contactThread.contactUUID.flatMap { try? ServiceId.parseFrom(serviceIdString: $0) }

        // If there's an ACI, it's *definitely* correct, and it's definitely the
        // owner, so we can return early without issuing any queries.
        if let aci = threadServiceId as? Aci {
            let ownedByRecipient = fetchRecipient(serviceId: aci, transaction: tx)

            return (aci, ownedByRecipient)
        }

        // Otherwise, we need to figure out which recipient "owns" this thread. If
        // the thread has a phone number but there's no SignalRecipient with that
        // phone number, we'll return nil (even if the thread has a PNI). This is
        // intentional. In this case, the phone number takes precedence, and this
        // PNI definitely isn’t associated with this phone number. This situation
        // should be impossible because ThreadMerger should keep these values in
        // sync. (It's pre-ThreadMerger threads that might be wrong, and PNIs were
        // introduced after ThreadMerger.)
        if let phoneNumber = contactThread.contactPhoneNumber {
            let ownedByRecipient = fetchRecipient(phoneNumber: phoneNumber, transaction: tx)
            let ownedByServiceId = ownedByRecipient?.aci ?? ownedByRecipient?.pni

            return ownedByServiceId.map { ($0, ownedByRecipient) }
        }

        if let pni = threadServiceId as? Pni {
            let ownedByRecipient = fetchRecipient(serviceId: pni, transaction: tx)
            let ownedByServiceId = ownedByRecipient?.aci ?? ownedByRecipient?.pni ?? pni

            return (ownedByServiceId, ownedByRecipient)
        }

        return nil
    }

    // MARK: -

    public func fetchRecipient(address: SignalServiceAddress, tx: DBReadTransaction) -> SignalRecipient? {
        return (
            address.serviceId.flatMap({ fetchRecipient(serviceId: $0, transaction: tx) })
            ?? address.phoneNumber.flatMap({ fetchRecipient(phoneNumber: $0, transaction: tx) })
        )
    }

    public func fetchAuthorRecipient(incomingMessage: TSIncomingMessage, tx: DBReadTransaction) -> SignalRecipient? {
        return fetchRecipient(address: incomingMessage.authorAddress, tx: tx)
    }

    public func fetchRecipient(rowId: Int64, tx: DBReadTransaction) -> SignalRecipient? {
        do {
            return try SignalRecipient.fetchOne(tx.database, key: rowId)
        } catch {
            let grdbError = error.grdbErrorForLogging
            DatabaseCorruptionState.flagDatabaseReadCorruptionIfNecessary(error: grdbError)
            owsFailDebug("\(grdbError)")
            return nil
        }
    }

    public func fetchRecipient(uniqueId: String, tx: DBReadTransaction) -> SignalRecipient? {
        let sql = "SELECT * FROM \(SignalRecipient.databaseTableName) WHERE \(signalRecipientColumn: .uniqueId) = ?"
        do {
            return try SignalRecipient.fetchOne(tx.database, sql: sql, arguments: [uniqueId])
        } catch {
            let grdbError = error.grdbErrorForLogging
            DatabaseCorruptionState.flagDatabaseReadCorruptionIfNecessary(error: grdbError)
            owsFailDebug("\(grdbError)")
            return nil
        }
    }

    public func fetchRecipient(serviceId: ServiceId, transaction tx: DBReadTransaction) -> SignalRecipient? {
        let serviceIdColumn: SignalRecipient.CodingKeys = {
            switch serviceId.kind {
            case .aci: return .aciString
            case .pni: return .pni
            }
        }()
        let sql = "SELECT * FROM \(SignalRecipient.databaseTableName) WHERE \(signalRecipientColumn: serviceIdColumn) = ?"
        do {
            return try SignalRecipient.fetchOne(tx.database, sql: sql, arguments: [serviceId.serviceIdUppercaseString])
        } catch {
            let grdbError = error.grdbErrorForLogging
            DatabaseCorruptionState.flagDatabaseReadCorruptionIfNecessary(error: grdbError)
            owsFailDebug("\(grdbError)")
            return nil
        }
    }

    public func fetchRecipient(phoneNumber: String, transaction tx: DBReadTransaction) -> SignalRecipient? {
        let sql = "SELECT * FROM \(SignalRecipient.databaseTableName) WHERE \(signalRecipientColumn: .phoneNumber) = ?"
        do {
            return try SignalRecipient.fetchOne(tx.database, sql: sql, arguments: [phoneNumber])
        } catch {
            let grdbError = error.grdbErrorForLogging
            DatabaseCorruptionState.flagDatabaseReadCorruptionIfNecessary(error: grdbError)
            owsFailDebug("\(grdbError)")
            return nil
        }
    }

    public func enumerateAll(tx: DBReadTransaction, block: (SignalRecipient) -> Void) {
        do {
            let cursor = try SignalRecipient.fetchCursor(tx.database)
            var hasMore = true
            while hasMore {
                try autoreleasepool {
                    guard let recipient = try cursor.next() else {
                        hasMore = false
                        return
                    }
                    block(recipient)
                }
            }
        } catch {
            let grdbError = error.grdbErrorForLogging
            DatabaseCorruptionState.flagDatabaseReadCorruptionIfNecessary(error: grdbError)
            owsFailDebug("\(grdbError)")
        }
    }

    public func fetchAllPhoneNumbers(tx: DBReadTransaction) -> [String: Bool] {
        var result = [String: Bool]()
        enumerateAll(tx: tx) { signalRecipient in
            guard let phoneNumber = signalRecipient.phoneNumber?.stringValue else {
                return
            }
            result[phoneNumber] = signalRecipient.isRegistered
        }
        return result
    }

    public func insertRecipient(_ signalRecipient: SignalRecipient, transaction: DBWriteTransaction) {
        failIfThrows {
            do {
                try signalRecipient.insert(transaction.database)
            } catch {
                throw error.grdbErrorForLogging
            }
        }
    }

    public func updateRecipient(_ signalRecipient: SignalRecipient, transaction: DBWriteTransaction) {
        failIfThrows {
            do {
                try signalRecipient.update(transaction.database)
            } catch {
                throw error.grdbErrorForLogging
            }
        }
    }

    public func removeRecipient(_ signalRecipient: SignalRecipient, transaction: DBWriteTransaction) {
        failIfThrows {
            do {
                try signalRecipient.delete(transaction.database)
            } catch {
                throw error.grdbErrorForLogging
            }
        }
    }
}
