//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import LibMunrChatClient

extension PublicKey {
    public convenience init(keyData: Data) throws {
        if keyData.count != Constants.keyLengthDJB {
            throw MunrChatError.invalidKey("invalid number of public key bytes (expected \(Constants.keyLengthDJB), was \(keyData.count))")
        }
        try self.init([Constants.keyTypeDJB] + keyData)
    }

    public enum Constants {
        public static let keyTypeDJB: UInt8 = 0x05
        public static let keyLengthDJB: Int = 32
    }
}
