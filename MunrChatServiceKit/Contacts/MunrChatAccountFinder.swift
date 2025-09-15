//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import GRDB
import LibMunrChatClient

public struct MunrChatAccountFinder {
    public init() {
    }

    public func MunrChatAccount(
        for e164: E164,
        tx: DBReadTransaction
    ) -> MunrChatAccount? {
        return MunrChatAccount(for: e164.stringValue, tx: tx)
    }

    func MunrChatAccount(
        for phoneNumber: String,
        tx: DBReadTransaction
    ) -> MunrChatAccount? {
        return MunrChatAccountWhere(
            column: MunrChatAccount.columnName(.recipientPhoneNumber),
            matches: phoneNumber,
            tx: tx
        )
    }

    func MunrChatAccounts(
        for phoneNumbers: [String],
        tx: DBReadTransaction
    ) -> [MunrChatAccount?] {
        return MunrChatAccountsForPhoneNumbers(phoneNumbers, tx: tx)
    }

    private func MunrChatAccountsForPhoneNumbers(
        _ phoneNumbers: [String?],
        tx: DBReadTransaction
    ) -> [MunrChatAccount?] {
        let accounts = MunrChatAccountsWhere(
            column: MunrChatAccount.columnName(.recipientPhoneNumber),
            anyValueIn: phoneNumbers.compacted(),
            tx: tx
        )

        let index: [String?: [MunrChatAccount?]] = Dictionary(grouping: accounts) { $0?.recipientPhoneNumber }
        return phoneNumbers.map { maybePhoneNumber -> MunrChatAccount? in
            guard
                let phoneNumber = maybePhoneNumber,
                let accountsForPhoneNumber = index[phoneNumber],
                let firstAccountForPhoneNumber = accountsForPhoneNumber.first
            else {
                return nil
            }

            return firstAccountForPhoneNumber
        }
    }

    private func MunrChatAccountsWhere(
        column: String,
        anyValueIn values: [String],
        tx: DBReadTransaction
    ) -> [MunrChatAccount?] {
        guard !values.isEmpty else {
            return []
        }
        let qms = Array(repeating: "?", count: values.count).joined(separator: ", ")
        let sql = "SELECT * FROM \(MunrChatAccount.databaseTableName) WHERE \(column) in (\(qms))"

        return allMunrChatAccounts(
            tx: tx,
            sql: sql,
            arguments: StatementArguments(values)
        )
    }

    private func MunrChatAccountWhere(
        column: String,
        matches matchString: String,
        tx: DBReadTransaction
    ) -> MunrChatAccount? {
        let sql = "SELECT * FROM \(MunrChatAccount.databaseTableName) WHERE \(column) = ? LIMIT 1"

        return allMunrChatAccounts(
            tx: tx,
            sql: sql,
            arguments: [matchString]
        ).first
    }

    private func allMunrChatAccounts(
        tx: DBReadTransaction,
        sql: String,
        arguments: StatementArguments
    ) -> [MunrChatAccount] {
        var result = [MunrChatAccount]()
        MunrChatAccount.anyEnumerate(
            transaction: tx,
            sql: sql,
            arguments: arguments
        ) { account, _ in
            result.append(account)
        }
        return result
    }

    func fetchPhoneNumbers(tx: DBReadTransaction) throws -> [String] {
        let sql = """
            SELECT \(MunrChatAccount.columnName(.recipientPhoneNumber)) FROM \(MunrChatAccount.databaseTableName)
        """
        do {
            return try String?.fetchAll(tx.database, sql: sql).compacted()
        } catch {
            throw error.grdbErrorForLogging
        }
    }
}
