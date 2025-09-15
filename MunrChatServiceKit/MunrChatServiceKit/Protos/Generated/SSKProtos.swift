//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

@objc
public class SSKProtos: NSObject {

    private override init() {}

    @objc
    public class var currentProtocolVersion: Int {
        // Our proto wrappers don't handle enum aliases, so we have one non-generated
        // wrapper for the "current" protocol version.
        return MunrChatServiceProtos_DataMessage.ProtocolVersion.current.rawValue
    }
}
