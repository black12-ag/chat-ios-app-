//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public struct DarwinNotificationName: ExpressibleByStringLiteral {
    public static let nseDidReceiveNotification: DarwinNotificationName = "org.MunrChat.nseDidReceiveNotification"
    public static let mainAppHandledNotification: DarwinNotificationName = "org.MunrChat.mainAppHandledNotification"
    public static let mainAppLaunched: DarwinNotificationName = "org.MunrChat.mainAppLaunched"
    static let primaryDBFolderNameDidChange: DarwinNotificationName = "org.MunrChat.primaryDBFolderNameDidChange"

    static func sdsCrossProcess(for type: AppContextType) -> DarwinNotificationName {
        DarwinNotificationName("org.MunrChat.sdscrossprocess.\(type)")
    }

    static func connectionLock(for priority: Int) -> DarwinNotificationName {
        return DarwinNotificationName("org.MunrChat.connection.\(priority)")
    }

    public typealias StringLiteralType = String

    public let rawValue: String

    public init(stringLiteral name: String) {
        owsPrecondition(!name.isEmpty)
        self.rawValue = name
    }

    public init(_ name: String) {
        owsAssertDebug(!name.isEmpty)
        self.rawValue = name
    }
}
