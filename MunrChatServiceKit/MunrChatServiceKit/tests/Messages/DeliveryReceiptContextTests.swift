//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import MunrChatServiceKit

class DeliveryReceiptContextTests: SSKBaseTest {
    func testExecutesDifferentMessages() throws {
        let aliceRecipient = MunrChatServiceAddress(phoneNumber: "+12345678900")
        var timestamp: UInt64?
        write { transaction in
            let aliceContactThread = TSContactThread.getOrCreateThread(withContactAddress: aliceRecipient, transaction: transaction)
            let helloAlice = TSOutgoingMessage(in: aliceContactThread, messageBody: "Hello Alice")
            helloAlice.anyInsert(transaction: transaction)
            timestamp = helloAlice.timestamp
        }
        XCTAssertNotNil(timestamp)
        write { transaction in
            var messages = [TSOutgoingMessage]()
            BatchingDeliveryReceiptContext.withDeferredUpdates(transaction: transaction) { context in
                let message = context.messages(timestamp!, transaction: transaction)[0]
                context.addUpdate(message: message, transaction: transaction) { m in
                    messages.append(m)
                }
            }
            XCTAssertEqual(messages.count, 2)
            XCTAssertFalse(messages[0] === messages[1])
        }

    }
}

// MARK: -

private extension TSOutgoingMessage {
    convenience init(in thread: TSThread, messageBody: String) {
        let builder: TSOutgoingMessageBuilder = .withDefaultValues(
            thread: thread,
            messageBody: AttachmentContentValidatorMock.mockValidatedBody(messageBody)
        )
        self.init(outgoingMessageWith: builder, recipientAddressStates: [:])
    }
}
