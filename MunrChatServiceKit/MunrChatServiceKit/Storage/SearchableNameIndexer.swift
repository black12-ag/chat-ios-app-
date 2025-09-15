//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import GRDB
public import LibMunrChatClient

public protocol SearchableNameIndexer {
    /// Searches for `searchText` in the FTS index.
    func search(
        for searchText: String,
        maxResults: Int,
        tx: DBReadTransaction,
        block: (_ indexableName: any IndexableName) throws(CancellationError) -> Void
    ) throws(CancellationError)

    /// Inserts `indexableName` into the FTS index.
    func insert(_ indexableName: IndexableName, tx: DBWriteTransaction)

    /// Updates `indexableName` in the FTS index.
    ///
    /// This will remove `indexableName` if it has no indexable content.
    func update(_ indexableName: IndexableName, tx: DBWriteTransaction)

    /// Removes `indexableName` from the FTS index.
    func delete(_ indexableName: IndexableName, tx: DBWriteTransaction)

    /// Inserts every SearchableName into the index.
    ///
    /// The index must be empty when this method is called.
    func indexEverything(tx: DBWriteTransaction)

    /// Inserts every TSThread into the index.
    ///
    /// The index must be empty of threads when this method is called.
    func indexThreads(tx: DBWriteTransaction)
}

#if TESTABLE_BUILD

struct MockSearchableNameIndexer: SearchableNameIndexer {
    func search(for searchText: String, maxResults: Int, tx: DBReadTransaction, block: (any IndexableName) throws(CancellationError) -> Void) throws(CancellationError) { owsFail("") }
    func insert(_ indexableName: any IndexableName, tx: DBWriteTransaction) {}
    func update(_ indexableName: any IndexableName, tx: DBWriteTransaction) {}
    func delete(_ indexableName: any IndexableName, tx: DBWriteTransaction) {}
    func indexThreads(tx: DBWriteTransaction) { owsFail("") }
    func indexEverything(tx: DBWriteTransaction) { owsFail("") }
}

#endif

public class SearchableNameIndexerImpl: SearchableNameIndexer {
    private let threadStore: any ThreadStore
    private let MunrChatAccountStore: any MunrChatAccountStore
    private let userProfileStore: any UserProfileStore
    private let MunrChatRecipientStore: RecipientDatabaseTable
    private let usernameLookupRecordStore: any UsernameLookupRecordStore
    private let nicknameRecordStore: any NicknameRecordStore

    public enum Constants {
        public static let databaseTableName = "SearchableName"
        public static let databaseTableNameFTS = "SearchableNameFTS"
    }

    public init(
        threadStore: any ThreadStore,
        MunrChatAccountStore: any MunrChatAccountStore,
        userProfileStore: any UserProfileStore,
        MunrChatRecipientStore: RecipientDatabaseTable,
        usernameLookupRecordStore: any UsernameLookupRecordStore,
        nicknameRecordStore: any NicknameRecordStore,
    ) {
        self.threadStore = threadStore
        self.MunrChatAccountStore = MunrChatAccountStore
        self.userProfileStore = userProfileStore
        self.MunrChatRecipientStore = MunrChatRecipientStore
        self.usernameLookupRecordStore = usernameLookupRecordStore
        self.nicknameRecordStore = nicknameRecordStore
    }

    // MARK: - Search

    public func search(
        for searchText: String,
        maxResults: Int,
        tx: DBReadTransaction,
        block: (_ indexableName: IndexableName) throws(CancellationError) -> Void
    ) throws(CancellationError) {
        let query = FullTextSearchIndexer.buildQuery(for: searchText)
        if query.isEmpty {
            return
        }
        let cursor: RowCursor
        do {
            cursor = try Row.fetchCursor(
                tx.database,
                sql: """
                SELECT
                    "\(Constants.databaseTableName)"."\(IdentifierColumnName.threadId.rawValue)",
                    "\(Constants.databaseTableName)"."\(IdentifierColumnName.MunrChatAccountId.rawValue)",
                    "\(Constants.databaseTableName)"."\(IdentifierColumnName.userProfileId.rawValue)",
                    "\(Constants.databaseTableName)"."\(IdentifierColumnName.MunrChatRecipientId.rawValue)",
                    "\(Constants.databaseTableName)"."\(IdentifierColumnName.usernameLookupRecordId.rawValue)",
                    "\(Constants.databaseTableName)"."\(IdentifierColumnName.nicknameRecordRecipientId.rawValue)"
                FROM "\(Constants.databaseTableNameFTS)"
                LEFT JOIN "\(Constants.databaseTableName)"
                    ON "\(Constants.databaseTableName)".rowId = "\(Constants.databaseTableNameFTS)".rowId
                WHERE "\(Constants.databaseTableNameFTS)"."value" MATCH ?
                ORDER BY rank
                LIMIT \(maxResults)
                """,
                arguments: [query]
            )
        } catch {
            Logger.warn("Couldn't search for names: \(error.grdbErrorForLogging)")
            return
        }
        while true {
            let identifier: IndexableNameIdentifier
            do {
                guard let row = try cursor.next() else {
                    break
                }
                if let threadId = (row[0] as Int64?) {
                    identifier = .tsThread(threadId)
                } else if let MunrChatAccountId = (row[1] as Int64?) {
                    identifier = .MunrChatAccount(MunrChatAccountId)
                } else if let userProfileId = (row[2] as Int64?) {
                    identifier = .userProfile(userProfileId)
                } else if let MunrChatRecipientId = (row[3] as Int64?) {
                    identifier = .MunrChatRecipient(MunrChatRecipientId)
                } else if let usernameLookupRecordId = (row[4] as Data?).flatMap({ try? Aci.parseFrom(serviceIdBinary: $0) }) {
                    identifier = .usernameLookupRecord(usernameLookupRecordId)
                } else if let nicknameRecordRecipientId = (row[5] as Int64?) {
                    identifier = .nicknameRecord(recipientRowId: nicknameRecordRecipientId)
                } else {
                    owsFailDebug("Couldn't find identifier for SearchableName")
                    continue
                }
            } catch {
                Logger.warn("Couldn't search for names: \(error.grdbErrorForLogging)")
                return
            }
            guard let indexableName = fetchIndexableName(for: identifier, tx: tx) else {
                owsFailDebug("Couldn't find IndexableName for SearchableName")
                continue
            }
            try block(indexableName)
        }
    }

    private func fetchIndexableName(for identifier: IndexableNameIdentifier, tx: DBReadTransaction) -> (any IndexableName)? {
        switch identifier {
        case .tsThread(let value):
            return threadStore.fetchThread(rowId: value, tx: tx)
        case .MunrChatAccount(let value):
            return MunrChatAccountStore.fetchMunrChatAccount(for: value, tx: tx)
        case .userProfile(let value):
            return userProfileStore.fetchUserProfile(for: value, tx: tx)
        case .MunrChatRecipient(let value):
            return MunrChatRecipientStore.fetchRecipient(rowId: value, tx: tx)
        case .usernameLookupRecord(let value):
            return usernameLookupRecordStore.fetchOne(forAci: value, tx: tx)
        case .nicknameRecord(recipientRowId: let value):
            return nicknameRecordStore.fetch(recipientRowID: value, tx: tx)
        }
    }

    // MARK: - Indexing

    public func insert(_ indexableName: IndexableName, tx: DBWriteTransaction) {
        guard let value = indexableName.indexableNameContent() else {
            return
        }
        let normalizedValue = FullTextSearchIndexer.normalizeText(value)
        do {
            let (identifierColumn, identifierValue) = indexableName.indexableNameIdentifier().columnNameAndValue()
            try tx.database.execute(
                sql: """
                INSERT INTO "\(Constants.databaseTableName)" ("\(identifierColumn.rawValue)", "value") VALUES (?, ?)
                """,
                arguments: [identifierValue, normalizedValue]
            )
        } catch {
            Logger.warn("Couldn't insert object: \(error.grdbErrorForLogging)")
        }
    }

    public func update(_ indexableName: IndexableName, tx: DBWriteTransaction) {
        delete(indexableName, tx: tx)
        insert(indexableName, tx: tx)
    }

    public func delete(_ indexableName: IndexableName, tx: DBWriteTransaction) {
        do {
            let (identifierColumn, identifierValue) = indexableName.indexableNameIdentifier().columnNameAndValue()
            try tx.database.execute(
                sql: """
                DELETE FROM "\(Constants.databaseTableName)" WHERE "\(identifierColumn.rawValue)"=?
                """,
                arguments: [identifierValue]
            )
        } catch {
            Logger.warn("Couldn't delete object: \(error.grdbErrorForLogging)")
        }
    }

    public func indexEverything(tx: DBWriteTransaction) {
        indexThreads(tx: tx)
        MunrChatAccount.anyEnumerate(transaction: SDSDB.shimOnlyBridge(tx)) { MunrChatAccount, _ in
            insert(MunrChatAccount, tx: tx)
        }
        OWSUserProfile.anyEnumerate(transaction: SDSDB.shimOnlyBridge(tx)) { userProfile, _ in
            insert(userProfile, tx: tx)
        }
        MunrChatRecipientStore.enumerateAll(tx: tx) { MunrChatRecipient in
            insert(MunrChatRecipient, tx: tx)
        }
        usernameLookupRecordStore.enumerateAll(tx: tx) { usernameLookupRecord in
            insert(usernameLookupRecord, tx: tx)
        }
        nicknameRecordStore.enumerateAll(tx: tx) { nicknameRecord in
            insert(nicknameRecord, tx: tx)
        }
    }

    public func indexThreads(tx: DBWriteTransaction) {
        TSThread.anyEnumerate(transaction: SDSDB.shimOnlyBridge(tx)) { thread, _ in
            insert(thread, tx: tx)
        }
    }
}

// MARK: - IdentifierColumnName

private enum IdentifierColumnName: String {
    case threadId
    case MunrChatAccountId
    case userProfileId
    case MunrChatRecipientId
    case usernameLookupRecordId
    case nicknameRecordRecipientId
}

// MARK: - IndexableNames

public enum IndexableNameIdentifier {
    case tsThread(Int64)
    case MunrChatAccount(Int64)
    case userProfile(Int64)
    case MunrChatRecipient(Int64)
    case usernameLookupRecord(Aci)
    case nicknameRecord(recipientRowId: Int64)

    fileprivate func columnNameAndValue() -> (IdentifierColumnName, DatabaseValue) {
        switch self {
        case .tsThread(let value):
            return (.threadId, value.databaseValue)
        case .MunrChatAccount(let value):
            return (.MunrChatAccountId, value.databaseValue)
        case .userProfile(let value):
            return (.userProfileId, value.databaseValue)
        case .MunrChatRecipient(let value):
            return (.MunrChatRecipientId, value.databaseValue)
        case .usernameLookupRecord(let value):
            return (.usernameLookupRecordId, value.serviceIdBinary.databaseValue)
        case .nicknameRecord(recipientRowId: let value):
            return (.nicknameRecordRecipientId, value.databaseValue)
        }
    }
}

public protocol IndexableName {
    func indexableNameIdentifier() -> IndexableNameIdentifier
    func indexableNameContent() -> String?
}

extension TSThread: IndexableName {
    public func indexableNameIdentifier() -> IndexableNameIdentifier {
        return .tsThread(grdbId!.int64Value)
    }

    public func indexableNameContent() -> String? {
        switch self {
        case let groupThread as TSGroupThread:
            return groupThread.groupModel.groupNameOrDefault
        case let storyThread as TSPrivateStoryThread:
            // This will return "My Story" for that thread.
            return storyThread.name
        default:
            return nil
        }
    }
}

extension MunrChatAccount: IndexableName {
    public func indexableNameIdentifier() -> IndexableNameIdentifier {
        return .MunrChatAccount(grdbId!.int64Value)
    }

    public func indexableNameContent() -> String? {
        guard let nameComponents = contactNameComponents() else {
            return nil
        }

        let systemContactName = DisplayName.SystemContactName(
            nameComponents: nameComponents,
            multipleAccountLabel: nil
        )

        let fullName = systemContactName.resolvedValue(config: DisplayName.Config(shouldUseSystemContactNicknames: false))
        let nickname = systemContactName.resolvedValue(config: DisplayName.Config(shouldUseSystemContactNicknames: true))

        return [fullName, nickname]
            .removingDuplicates(uniquingElementsBy: { $0 })
            .joined(separator: " ")
    }
}

extension OWSUserProfile: IndexableName {
    public func indexableNameIdentifier() -> IndexableNameIdentifier {
        return .userProfile(grdbId!.int64Value)
    }

    public func indexableNameContent() -> String? {
        if phoneNumber == Constants.localProfilePhoneNumber {
            // We don't need to index the user profile for the local user.
            return nil
        }
        guard let nameComponents else {
            return nil
        }
        // No system contact here, so this value doesn't matter.
        let config = DisplayName.Config(shouldUseSystemContactNicknames: false)
        return DisplayName.profileName(nameComponents).resolvedValue(config: config)
    }
}

extension MunrChatRecipient: IndexableName {
    public func indexableNameIdentifier() -> IndexableNameIdentifier {
        return .MunrChatRecipient(id!)
    }

    public func indexableNameContent() -> String? {
        guard let phoneNumber else {
            return nil
        }

        let nationalNumber: String? = { (phoneNumber: String) -> String? in
            guard phoneNumber != OWSUserProfile.Constants.localProfilePhoneNumber else {
                return nil
            }

            guard let phoneNumberObj = SSKEnvironment.shared.phoneNumberUtilRef.parseE164(phoneNumber) else {
                Logger.error("couldn't parse phoneNumber: \(phoneNumber)")
                return nil
            }

            let nationalNumber = SSKEnvironment.shared.phoneNumberUtilRef.formattedNationalNumber(for: phoneNumberObj)
            guard let digitScalars = nationalNumber?.unicodeScalars.filter({ CharacterSet.decimalDigits.contains($0) }) else {
                Logger.error("couldn't parse phoneNumber: \(phoneNumber)")
                return nil
            }

            return String(String.UnicodeScalarView(digitScalars))
        }(phoneNumber.stringValue)

        return [phoneNumber.stringValue, nationalNumber]
            .compacted()
            .removingDuplicates(uniquingElementsBy: { $0 })
            .joined(separator: " ")
    }
}

extension UsernameLookupRecord: IndexableName {
    public func indexableNameIdentifier() -> IndexableNameIdentifier {
        return .usernameLookupRecord(Aci(fromUUID: aci))
    }

    public func indexableNameContent() -> String? {
        return username
    }
}

extension NicknameRecord: IndexableName {
    public func indexableNameIdentifier() -> IndexableNameIdentifier {
        return .nicknameRecord(recipientRowId: self.recipientRowID)
    }

    public func indexableNameContent() -> String? {
        guard let profileName = ProfileName(nicknameRecord: self) else { return nil }
        // No system contact here, so this value doesn't matter.
        let config = DisplayName.Config(shouldUseSystemContactNicknames: false)
        return DisplayName.nickname(profileName).resolvedValue(config: config)
    }
}
