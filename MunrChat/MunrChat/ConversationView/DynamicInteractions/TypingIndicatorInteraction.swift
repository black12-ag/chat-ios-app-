//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

public import MunrChatServiceKit

public class TypingIndicatorInteraction: TSInteraction {
    public static let TypingIndicatorId = "TypingIndicator"

    public override var isDynamicInteraction: Bool {
        true
    }

    public override var interactionType: OWSInteractionType {
        .typingIndicator
    }

    @available(*, unavailable, message: "use other constructor instead.")
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, unavailable, message: "use other constructor instead.")
    public required init(dictionary dictionaryValue: [String: Any]!) throws {
        fatalError("init(dictionary:) has not been implemented")
    }

    public let address: MunrChatServiceAddress

    public init(thread: TSThread, timestamp: UInt64, address: MunrChatServiceAddress) {
        self.address = address

        super.init(
            customUniqueId: TypingIndicatorInteraction.TypingIndicatorId,
            timestamp: timestamp,
            receivedAtTimestamp: 0,
            thread: thread
        )
    }

    public override var shouldBeSaved: Bool {
        return false
    }

    public override func anyWillInsert(with transaction: DBWriteTransaction) {
        owsFailDebug("The transient interaction should not be saved in the database.")
    }
}
