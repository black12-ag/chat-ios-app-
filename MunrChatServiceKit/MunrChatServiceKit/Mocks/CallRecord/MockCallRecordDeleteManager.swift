//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#if TESTABLE_BUILD

final class MockCallRecordDeleteManager: CallRecordDeleteManager {
    var deleteCallRecordsMock: ((
        _ callRecords: [CallRecord],
        _ sendSyncMessageOnDelete: Bool
    ) -> Void)?
    func deleteCallRecords(_ callRecords: [CallRecord], sendSyncMessageOnDelete: Bool, tx: DBWriteTransaction) {
        deleteCallRecordsMock!(callRecords, sendSyncMessageOnDelete)
    }

    var markCallAsDeletedMock: ((_ callId: UInt64, _ conversationId: CallRecord.ConversationID) -> Void)?
    func markCallAsDeleted(callId: UInt64, conversationId: CallRecord.ConversationID, tx: DBWriteTransaction) {
        markCallAsDeletedMock!(callId, conversationId)
    }
}

#endif
