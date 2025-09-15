//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import XCTest
import MunrChatServiceKit

class TypingIndicatorMessageTest: SSKBaseTest {
    private func makeThread(transaction: DBWriteTransaction) -> TSThread {
        TSContactThread.getOrCreateThread(
            withContactAddress: MunrChatServiceAddress(phoneNumber: "+12223334444"),
            transaction: transaction
        )
    }

    func testIsOnline() throws {
        write { transaction in
            let message = TypingIndicatorMessage(
                thread: makeThread(transaction: transaction),
                action: .started,
                transaction: transaction
            )
            XCTAssertTrue(message.isOnline)
        }
    }

    func testIsUrgent() throws {
        write { transaction in
            let message = TypingIndicatorMessage(
                thread: makeThread(transaction: transaction),
                action: .started,
                transaction: transaction
            )
            XCTAssertFalse(message.isUrgent)
        }
    }
}
