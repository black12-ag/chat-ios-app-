//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

/// A logger for call record-related events.
public final class CallRecordLogger: PrefixedLogger {
    public static let shared = CallRecordLogger()

    private init() {
        super.init(prefix: "[CallRecord]")
    }
}
