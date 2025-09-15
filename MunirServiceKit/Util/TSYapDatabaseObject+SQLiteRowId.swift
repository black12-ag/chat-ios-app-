//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

public extension TSYapDatabaseObject {
    var sqliteRowId: Int64? {
        return grdbId?.int64Value
    }
}
