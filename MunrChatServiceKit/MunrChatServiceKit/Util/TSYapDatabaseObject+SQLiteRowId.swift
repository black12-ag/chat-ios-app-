//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

public extension TSYapDatabaseObject {
    var sqliteRowId: Int64? {
        return grdbId?.int64Value
    }
}
