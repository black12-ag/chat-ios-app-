//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibMunrChatClient

extension GroupManager {
    // Serialize group updates by group ID
    private static let groupUpdateOperationQueues = AtomicValue<[Data: SerialTaskQueue]>([:], lock: .init())

    private static func operationQueue(
        forUpdatingGroup groupModel: TSGroupModel
    ) -> SerialTaskQueue {
        return groupUpdateOperationQueues.update {
            if let operationQueue = $0[groupModel.groupId] {
                return operationQueue
            }
            let operationQueue = SerialTaskQueue()
            $0[groupModel.groupId] = operationQueue
            return operationQueue
        }
    }

    private enum GenericGroupUpdateOperation {
        static func run(
            groupSecretParamsData: Data,
            updateDescription: String,
            changesBlock: @escaping (GroupsV2OutgoingChanges) -> Void
        ) async throws {
            do {
                try await Promise.wrapAsync {
                    try await self._run(groupSecretParamsData: groupSecretParamsData, changesBlock: changesBlock)
                }.timeout(seconds: GroupManager.groupUpdateTimeoutDuration, description: updateDescription) {
                    return GroupsV2Error.timeout
                }.awaitable()
            } catch {
                switch error {
                case GroupsV2Error.redundantChange:
                    // From an operation perspective, this is a success!
                    break
                default:
                    owsFailDebug("Group update failed: \(error)")
                }
                throw error
            }
        }

        private static func _run(
            groupSecretParamsData: Data,
            changesBlock: (GroupsV2OutgoingChanges) -> Void
        ) async throws {
            try await GroupManager.ensureLocalProfileHasCommitmentIfNecessary()

            try await SSKEnvironment.shared.groupsV2Ref.updateGroupV2(
                secretParams: try GroupSecretParams(contents: groupSecretParamsData),
                changesBlock: changesBlock
            )
        }
    }

    public static func updateGroupV2(
        groupModel: TSGroupModelV2,
        description: String,
        changesBlock: @escaping (GroupsV2OutgoingChanges) -> Void
    ) async throws {
        try await operationQueue(forUpdatingGroup: groupModel).enqueue {
            try await GenericGroupUpdateOperation.run(
                groupSecretParamsData: groupModel.secretParamsData,
                updateDescription: description,
                changesBlock: changesBlock
            )
        }.value
    }
}
