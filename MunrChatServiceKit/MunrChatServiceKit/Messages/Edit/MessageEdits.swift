//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

/// A set of changes to the prior revision of a message when appying an edit.
///
/// Excluding attachment-related edits, this is a complete set of what is
/// _allowed_ to be edited and how it is edited.
public struct MessageEdits {
    public enum Edit<T> {
        case keep
        case change(T)

        func unwrapChange(orKeepValue keepValue: T) -> T {
            switch self {
            case .keep:
                return keepValue
            case .change(let t):
                return t
            }
        }
    }

    /// - SeeAlso ``TSMessage/body``
    public let body: Edit<ValidatedInlineMessageBody?>

    /// - SeeAlso ``TSInteraction/timestamp``
    public let timestamp: Edit<UInt64>
    /// - SeeAlso ``TSInteraction/receivedAtTimestamp``
    public let receivedAtTimestamp: Edit<UInt64>

    /// - SeeAlso ``TSIncomingMessage/serverTimestamp``
    public let serverTimestamp: Edit<UInt64>
    /// - SeeAlso ``TSIncomingMessage/serverDeliveryTimestamp``
    public let serverDeliveryTimestamp: Edit<UInt64>
    /// - SeeAlso ``TSIncomingMessage/serverGuid``
    public let serverGuid: Edit<String?>

    // MARK: -

    public static func forIncomingEdit(
        timestamp: Edit<UInt64>,
        receivedAtTimestamp: Edit<UInt64>,
        serverTimestamp: Edit<UInt64>,
        serverDeliveryTimestamp: Edit<UInt64>,
        serverGuid: Edit<String?>,
        body: Edit<ValidatedInlineMessageBody?>,
    ) -> MessageEdits {
        return MessageEdits(
            timestamp: timestamp,
            receivedAtTimestamp: receivedAtTimestamp,
            serverTimestamp: serverTimestamp,
            serverDeliveryTimestamp: serverDeliveryTimestamp,
            serverGuid: serverGuid,
            body: body,
        )
    }

    public static func forOutgoingEdit(
        timestamp: Edit<UInt64>,
        receivedAtTimestamp: Edit<UInt64>,
        body: Edit<ValidatedInlineMessageBody?>,
    ) -> MessageEdits {
        return MessageEdits(
            timestamp: timestamp,
            receivedAtTimestamp: receivedAtTimestamp,
            // Not relevant to outgoing edits.
            serverTimestamp: .keep,
            // Not relevant to outgoing edits.
            serverDeliveryTimestamp: .keep,
            // Not relevant to outgoing edits.
            serverGuid: .keep,
            body: body,
        )
    }

    /// Returns a `MessageEdits` object that describes no actual changes.
    public static func noChanges() -> MessageEdits {
        return MessageEdits(
            timestamp: .keep,
            receivedAtTimestamp: .keep,
            serverTimestamp: .keep,
            serverDeliveryTimestamp: .keep,
            serverGuid: .keep,
            body: .keep,
        )
    }

    private init(
        timestamp: Edit<UInt64>,
        receivedAtTimestamp: Edit<UInt64>,
        serverTimestamp: Edit<UInt64>,
        serverDeliveryTimestamp: Edit<UInt64>,
        serverGuid: Edit<String?>,
        body: Edit<ValidatedInlineMessageBody?>,
    ) {
        self.timestamp = timestamp
        self.receivedAtTimestamp = receivedAtTimestamp
        self.serverTimestamp = serverTimestamp
        self.serverDeliveryTimestamp = serverDeliveryTimestamp
        self.serverGuid = serverGuid
        self.body = body
    }
}
