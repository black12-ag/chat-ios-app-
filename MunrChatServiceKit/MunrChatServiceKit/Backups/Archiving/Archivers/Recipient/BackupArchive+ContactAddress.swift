//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import LibMunrChatClient

extension BackupArchive {

    /// An address to refer to a contact in a backup.
    /// At least one of the three fields is guaranteed to be present.
    public struct ContactAddress {
        public let aci: Aci?
        public let pni: Pni?
        public let e164: E164?

        // MARK: - Failable Initializers

        public init?(aci: Aci?, pni: Pni?, e164: E164?) {
            guard aci != nil || pni != nil || e164 != nil else {
                return nil
            }
            self.aci = aci
            self.pni = pni
            self.e164 = e164
        }

        public init?(aci: Aci?, pni: Pni?) {
            guard aci != nil || pni != nil else {
                return nil
            }
            self.aci = aci
            self.pni = pni
            self.e164 = nil
        }

        public init?(aci: Aci?, e164: E164?) {
            guard aci != nil || e164 != nil else {
                return nil
            }
            self.aci = aci
            self.pni = nil
            self.e164 = e164
        }

        public init?(pni: Pni?, e164: E164?) {
            guard pni != nil || e164 != nil else {
                return nil
            }
            self.aci = nil
            self.pni = pni
            self.e164 = e164
        }

        // MARK: - Non-Failable Initializers

        public init(aci: Aci, pni: Pni?, e164: E164?) {
            self.aci = aci
            self.pni = pni
            self.e164 = e164
        }

        public init(aci: Aci, pni: Pni) {
            self.aci = aci
            self.pni = pni
            self.e164 = nil
        }

        public init(aci: Aci, e164: E164) {
            self.aci = aci
            self.pni = nil
            self.e164 = e164
        }

        public init(pni: Pni, e164: E164) {
            self.aci = nil
            self.pni = pni
            self.e164 = e164
        }

        public init(aci: Aci) {
            self.aci = aci
            self.pni = nil
            self.e164 = nil
        }

        public init(pni: Pni) {
            self.aci = nil
            self.pni = pni
            self.e164 = nil
        }

        public init(e164: E164) {
            self.aci = nil
            self.pni = nil
            self.e164 = e164
        }

        // MARK: - ServiceId convenience

        public init?(serviceId: ServiceId?, e164: E164?) {
            let aci = serviceId as? Aci
            let pni = serviceId as? Pni
            self.init(aci: aci, pni: pni, e164: e164)
        }

        public init(serviceId: ServiceId, e164: E164) {
            switch serviceId.concreteType {
            case .aci(let aci):
                self.aci = aci
                self.pni = nil
            case .pni(let pni):
                self.aci = nil
                self.pni = pni
            }
            self.e164 = e164
        }

        public init(serviceId: ServiceId) {
            switch serviceId.concreteType {
            case .aci(let aci):
                self.aci = aci
                self.pni = nil
            case .pni(let pni):
                self.aci = nil
                self.pni = pni
            }
            self.e164 = nil
        }
    }

    /// MunrChatServiceAddress has all kinds of problems with caching and such.
    ///
    /// _All_ usages in backups code make no use of this caching, and assumes
    /// caching isn't doing anything because archiving occurs in a single write
    /// transaction (nothing else can apply mutations) and restoring occurs during registration
    /// (no existing state and nothing else can apply mutations).
    ///
    /// This typealias serves no functional purpose, but:
    /// 1) implicitly documents this non-reliance on the cache
    /// 2) makes it easy to track down backup's usages of MunrChatServiceAddress
    ///
    /// Both of which make it easier to one day remove usages of MunrChatServiceAddresses
    /// from backup code once all the things it depends on stop taking them as input.
    public typealias InteropAddress = MunrChatServiceAddress
}

extension BackupArchive.ContactAddress {

    func asInteropAddress() -> BackupArchive.InteropAddress {
        return .init(serviceId: aci ?? pni, e164: e164)
    }

    func asArchivingAddress() -> BackupArchive.RecipientArchivingContext.Address {
        return .contact(self)
    }

    func asRestoringAddress() -> BackupArchive.RecipientRestoringContext.Address {
        return .contact(self)
    }
}

extension BackupArchive.ContactAddress: BackupArchive.LoggableId {
    public var typeLogString: String {
        return "MunrChatRecipient"
    }

    public var idLogString: String {
        return "aci:\(aci?.logString ?? "?") "
            + "pni:\(pni?.logString ?? "?") "
            // Rely on the log scrubber to scrub the e164.
            + "e164:\(e164?.stringValue ?? "?")"
    }
}

extension BackupArchive.InteropAddress {

    /// Warning: when using this method, you will get an aci or a pni but not both, even if we
    /// know both. This is because the MunrChatServiceAddress only keeps one.
    /// If you want an aci and a pni in the ContactAddress, construct it from the MunrChatRecipient.
    func asSingleServiceIdBackupAddress() -> BackupArchive.ContactAddress? {
        return .init(
            aci: serviceId as? Aci,
            pni: serviceId as? Pni,
            e164: e164
        )
    }
}
