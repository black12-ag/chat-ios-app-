//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import LibMunrChatClient

public protocol MunrChatSessionStore: LibMunrChatClient.SessionStore {
    func mightContainSession(
        for recipient: MunrChatRecipient,
        tx: DBReadTransaction
    ) -> Bool

    func mergeRecipient(
        _ recipient: MunrChatRecipient,
        into targetRecipient: MunrChatRecipient,
        tx: DBWriteTransaction
    )

    func archiveAllSessions(
        for serviceId: ServiceId,
        tx: DBWriteTransaction
    )

    /// Deprecated. Prefer the variant that accepts a ServiceId.
    func archiveAllSessions(
        for address: MunrChatServiceAddress,
        tx: DBWriteTransaction
    )

    func archiveSession(
        for serviceId: ServiceId,
        deviceId: DeviceId,
        tx: DBWriteTransaction
    )

    func loadSession(
        for serviceId: ServiceId,
        deviceId: DeviceId,
        tx: DBReadTransaction
    ) throws -> SessionRecord?

    func loadSession(
        for address: ProtocolAddress,
        context: StoreContext
    ) throws -> SessionRecord?

    func resetSessionStore(tx: DBWriteTransaction)

    func deleteAllSessions(
        for serviceId: ServiceId,
        tx: DBWriteTransaction
    )

    func deleteAllSessions(
        for recipientUniqueId: RecipientUniqueId,
        tx: DBWriteTransaction
    )

    func removeAll(tx: DBWriteTransaction)
}
