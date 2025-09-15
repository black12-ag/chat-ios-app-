//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

/// Represents an interaction that may be associated with a ``CallRecord``.
public protocol CallRecordAssociatedInteraction: TSInteraction {}

public extension CallRecord {
    static func assertDebugIsCallRecordInteraction(_ interaction: TSInteraction) {
        owsAssertDebug(
            interaction is CallRecordAssociatedInteraction,
            "Unexpected associated interaction type: \(type(of: interaction))"
        )
    }
}

// MARK: -

extension TSCall: CallRecordAssociatedInteraction {}
extension OWSGroupCallMessage: CallRecordAssociatedInteraction {}
