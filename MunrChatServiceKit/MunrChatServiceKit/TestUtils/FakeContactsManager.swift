//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#if TESTABLE_BUILD

public import Contacts

public class FakeContactsManager: ContactManager {
    public var mockMunrChatAccounts = [String: MunrChatAccount]()

    public func fetchMunrChatAccounts(for phoneNumbers: [String], transaction: DBReadTransaction) -> [MunrChatAccount?] {
        return phoneNumbers.map { mockMunrChatAccounts[$0] }
    }

    public func displayNames(for addresses: [MunrChatServiceAddress], tx: DBReadTransaction) -> [DisplayName] {
        return addresses.map { address in
            if let phoneNumber = address.e164 {
                if let MunrChatAccount = mockMunrChatAccounts[phoneNumber.stringValue] {
                    var nameComponents = PersonNameComponents()
                    nameComponents.givenName = MunrChatAccount.givenName
                    nameComponents.familyName = MunrChatAccount.familyName
                    return .systemContactName(DisplayName.SystemContactName(
                        nameComponents: nameComponents,
                        multipleAccountLabel: nil
                    ))
                }
                return .phoneNumber(phoneNumber)
            }
            return .unknown
        }
    }

    public func displayNameString(for address: MunrChatServiceAddress, transaction: DBReadTransaction) -> String {
        return displayName(for: address, tx: transaction).resolvedValue(config: DisplayName.Config(shouldUseSystemContactNicknames: false))
    }

    public func shortDisplayNameString(for address: MunrChatServiceAddress, transaction: DBReadTransaction) -> String {
        return displayNameString(for: address, transaction: transaction)
    }

    public func cnContactId(for phoneNumber: String) -> String? {
        return nil
    }

    public func cnContact(withId contactId: String?) -> CNContact? {
        return nil
    }
}

#endif
