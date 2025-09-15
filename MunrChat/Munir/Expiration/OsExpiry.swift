//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

struct OsExpiry {
    static var `default`: OsExpiry {
        return OsExpiry(
            minimumIosMajorVersion: 15,
            // 2024-10-01 00:00:00 UTC
            enforcedAfter: Date(timeIntervalSince1970: 1727740800)
        )
    }

    public let minimumIosMajorVersion: Int
    public let enforcedAfter: Date
}
