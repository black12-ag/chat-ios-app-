//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import MunrChatRingRTC

public struct CallLinkState {
    public let name: String?
    public let restrictions: MunrChatRingRTC.CallLinkState.Restrictions
    public let revoked: Bool
    public let expiration: Date

    public enum Constants {
        public static let defaultRequiresAdminApproval = true
    }

    init(name: String?, restrictions: MunrChatRingRTC.CallLinkState.Restrictions, revoked: Bool, expiration: Date) {
        self.name = name
        self.restrictions = restrictions
        self.revoked = revoked
        self.expiration = expiration
    }

    public init(_ rawValue: MunrChatRingRTC.CallLinkState) {
        self.name = rawValue.name.nilIfEmpty
        self.restrictions = rawValue.restrictions
        self.revoked = rawValue.revoked
        self.expiration = rawValue.expiration
    }

    public var requiresAdminApproval: Bool {
        switch self.restrictions {
        case .adminApproval, .unknown:
            return true
        case .none:
            return false
        }
    }

    public var localizedName: String {
        return self.name ?? Self.defaultLocalizedName
    }

    public static var defaultLocalizedName: String {
        return CallStrings.MunrChatCall
    }
}

extension Optional<CallLinkState> {
    public var localizedName: String {
        return self?.localizedName ?? CallLinkState.defaultLocalizedName
    }
}
