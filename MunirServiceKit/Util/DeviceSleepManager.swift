//
// Copyright 2017 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public class DeviceSleepBlockObject {
    public let blockReason: String
    public init(blockReason: String) {
        self.blockReason = blockReason
    }
}

@MainActor
public protocol DeviceSleepManager {
    func addBlock(blockObject: DeviceSleepBlockObject)
    func removeBlock(blockObject: DeviceSleepBlockObject)
}
