//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

/// This token should be saved when receiving envelopes and provided to the server when reporting
/// spam.
public struct SpamReportingToken: Codable, Hashable, Sendable {
    let data: Data

    /// Creates a spam reporting token.
    ///
    /// Returns `nil` if the data is empty.
    public init?(data: Data) {
        if data.isEmpty { return nil }
        self.data = data
    }

    /// Convert this token to a base64-encoded string.
    public func base64EncodedString() -> String { data.base64EncodedString() }
}
