//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

#if TESTABLE_BUILD

open class SentMessageTranscriptReceiverMock: SentMessageTranscriptReceiver {

    public init() {}

    public func process(
        _: SentMessageTranscript,
        localIdentifiers: LocalIdentifiers,
        tx: DBWriteTransaction
    ) -> Result<TSOutgoingMessage?, Error> {
        // Do nothing
        return .success(nil)
    }
}

#endif
