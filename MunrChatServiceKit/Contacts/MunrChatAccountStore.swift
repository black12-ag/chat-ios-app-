//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public protocol MunrChatAccountStore {
    func fetchMunrChatAccount(for rowId: MunrChatAccount.RowId, tx: DBReadTransaction) -> MunrChatAccount?
}

public class MunrChatAccountStoreImpl: MunrChatAccountStore {
    public init() {}

    public func fetchMunrChatAccount(for rowId: MunrChatAccount.RowId, tx: DBReadTransaction) -> MunrChatAccount? {
        return SDSCodableModelDatabaseInterfaceImpl().fetchModel(modelType: MunrChatAccount.self, rowId: rowId, tx: tx)
    }
}
