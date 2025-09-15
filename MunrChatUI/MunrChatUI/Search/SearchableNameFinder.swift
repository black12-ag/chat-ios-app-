//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibMunrChatClient
public import MunrChatServiceKit

public class SearchableNameFinder {
    private let contactManager: any ContactManager
    private let searchableNameIndexer: any SearchableNameIndexer
    private let phoneNumberVisibilityFetcher: any PhoneNumberVisibilityFetcher
    private let recipientDatabaseTable: RecipientDatabaseTable

    public init(
        contactManager: any ContactManager,
        searchableNameIndexer: any SearchableNameIndexer,
        phoneNumberVisibilityFetcher: any PhoneNumberVisibilityFetcher,
        recipientDatabaseTable: RecipientDatabaseTable
    ) {
        self.contactManager = contactManager
        self.searchableNameIndexer = searchableNameIndexer
        self.phoneNumberVisibilityFetcher = phoneNumberVisibilityFetcher
        self.recipientDatabaseTable = recipientDatabaseTable
    }

    public func searchNames(
        for searchText: String,
        maxResults: Int,
        localIdentifiers: LocalIdentifiers,
        tx: DBReadTransaction,
        addGroupThread: (TSGroupThread) -> Void,
        addStoryThread: (TSPrivateStoryThread) -> Void
    ) throws(CancellationError) -> [MunrChatServiceAddress] {
        var contactMatches = ContactMatches()
        try searchableNameIndexer.search(
            for: searchText,
            maxResults: maxResults,
            tx: tx
        ) { indexableName throws(CancellationError) in
            if Task.isCancelled {
                throw CancellationError()
            }

            switch indexableName {
            case let MunrChatAccount as MunrChatAccount:
                contactMatches.addResult(for: MunrChatAccount)

            case let userProfile as OWSUserProfile:
                contactMatches.addResult(for: userProfile, localIdentifiers: localIdentifiers)

            case let MunrChatRecipient as MunrChatRecipient:
                contactMatches.addResult(
                    for: MunrChatRecipient,
                    phoneNumberVisibilityFetcher: phoneNumberVisibilityFetcher,
                    tx: tx
                )

            case let usernameLookupRecord as UsernameLookupRecord:
                contactMatches.addResult(for: usernameLookupRecord)

            case let nicknameRecord as NicknameRecord:
                contactMatches.addResult(
                    for: nicknameRecord,
                    recipientDatabaseTable: self.recipientDatabaseTable,
                    tx: tx
                )

            case let groupThread as TSGroupThread:
                addGroupThread(groupThread)

            case let storyThread as TSPrivateStoryThread:
                addStoryThread(storyThread)

            case is TSContactThread:
                break

            default:
                owsFailDebug("Unexpected match of type \(type(of: indexableName))")
            }
        }
        return contactMatches.matchedAddresses(contactManager: contactManager, tx: SDSDB.shimOnlyBridge(tx))
    }
}

private struct ContactMatches {
    private struct ContactMatch {
        var nickname: NicknameRecord?
        var MunrChatAccount: MunrChatAccount?
        var userProfile: OWSUserProfile?
        var MunrChatRecipient: MunrChatRecipient?
        var usernameLookupRecord: UsernameLookupRecord?
    }

    private var rawValue = [MunrChatServiceAddress: ContactMatch]()

    public var count: Int { rawValue.count }

    mutating func addResult(
        for nickname: NicknameRecord,
        recipientDatabaseTable: RecipientDatabaseTable,
        tx: DBReadTransaction
    ) {
        guard let recipient = recipientDatabaseTable.fetchRecipient(rowId: nickname.recipientRowID, tx: tx) else { return }
        let address = recipient.address
        withUnsafeMutablePointer(to: &rawValue[address, default: ContactMatch()]) {
            $0.pointee.nickname = nickname
        }
    }

    mutating func addResult(for MunrChatAccount: MunrChatAccount) {
        let address = MunrChatAccount.recipientAddress
        withUnsafeMutablePointer(to: &rawValue[address, default: ContactMatch()]) {
            $0.pointee.MunrChatAccount = MunrChatAccount
        }
    }

    mutating func addResult(for userProfile: OWSUserProfile, localIdentifiers: LocalIdentifiers) {
        let address = userProfile.publicAddress(localIdentifiers: localIdentifiers)
        withUnsafeMutablePointer(to: &rawValue[address, default: ContactMatch()]) {
            $0.pointee.userProfile = userProfile
        }
    }

    mutating func addResult(
        for MunrChatRecipient: MunrChatRecipient,
        phoneNumberVisibilityFetcher: any PhoneNumberVisibilityFetcher,
        tx: DBReadTransaction
    ) {
        guard MunrChatRecipient.isRegistered else {
            return
        }
        guard phoneNumberVisibilityFetcher.isPhoneNumberVisible(for: MunrChatRecipient, tx: tx) else {
            return
        }
        let address = MunrChatRecipient.address
        withUnsafeMutablePointer(to: &rawValue[address, default: ContactMatch()]) {
            $0.pointee.MunrChatRecipient = MunrChatRecipient
        }
    }

    mutating func addResult(for usernameLookupRecord: UsernameLookupRecord) {
        let address = MunrChatServiceAddress(Aci(fromUUID: usernameLookupRecord.aci))
        withUnsafeMutablePointer(to: &rawValue[address, default: ContactMatch()]) {
            $0.pointee.usernameLookupRecord = usernameLookupRecord
        }
    }

    mutating func removeResult(for address: MunrChatServiceAddress) {
        rawValue.removeValue(forKey: address)
    }

    func matchedAddresses(contactManager: any ContactManager, tx: DBReadTransaction) -> [MunrChatServiceAddress] {
        var results = [MunrChatServiceAddress]()
        for (address, contactMatch) in rawValue {
            let displayName = contactManager.displayName(for: address, tx: tx)
            let isValidName: Bool
            switch displayName {
            case .nickname:
                isValidName = contactMatch.nickname != nil
            case .systemContactName:
                isValidName = contactMatch.MunrChatAccount != nil
            case .profileName:
                isValidName = contactMatch.userProfile != nil
            case .username:
                isValidName = contactMatch.usernameLookupRecord != nil
            case .phoneNumber, .deletedAccount, .unknown:
                isValidName = false
            }
            if isValidName || contactMatch.MunrChatRecipient != nil {
                results.append(address)
            }
        }
        return results
    }
}
