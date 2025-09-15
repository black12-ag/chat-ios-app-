//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import GRDB
import LibMunrChatClient

@objc
public class ContactThreadFinder: NSObject {
    @objc(contactThreadForAddress:transaction:)
    public func contactThread(for address: MunrChatServiceAddress, tx: DBReadTransaction) -> TSContactThread? {
        if let serviceId = address.serviceId, let thread = contactThreads(for: serviceId, tx: tx).first {
            return thread
        }
        if let phoneNumber = address.phoneNumber, let thread = contactThreads(for: phoneNumber, tx: tx).first {
            return thread
        }
        return nil
    }

    func contactThreads(for serviceId: ServiceId, tx: DBReadTransaction) -> [TSContactThread] {
        let serviceIdString = serviceId.serviceIdUppercaseString
        let sql = "SELECT * FROM \(ThreadRecord.databaseTableName) WHERE \(threadColumn: .contactUUID) = ?"
        return fetchContactThreads(sql: sql, arguments: [serviceIdString], tx: tx)
    }

    func contactThreads(for phoneNumber: String, tx: DBReadTransaction) -> [TSContactThread] {
        let sql = "SELECT * FROM \(ThreadRecord.databaseTableName) WHERE \(threadColumn: .contactPhoneNumber) = ?"
        return fetchContactThreads(sql: sql, arguments: [phoneNumber], tx: tx)
    }

    private func fetchContactThreads(sql: String, arguments: StatementArguments, tx: DBReadTransaction) -> [TSContactThread] {
        do {
            let threads = try TSContactThread.grdbFetchCursor(
                sql: sql,
                arguments: arguments,
                transaction: tx
            ).all()
            return threads.compactMap { $0 as? TSContactThread }
        } catch {
            return []
        }
    }
}
