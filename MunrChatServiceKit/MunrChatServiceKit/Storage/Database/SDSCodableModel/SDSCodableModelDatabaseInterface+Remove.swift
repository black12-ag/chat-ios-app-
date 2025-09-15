//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

extension SDSCodableModelDatabaseInterfaceImpl {

    /// Remove a model from the database.
    func removeModel<Model: SDSCodableModel>(
        _ model: Model,
        transaction: DBWriteTransaction
    ) {
        let transaction = SDSDB.shimOnlyBridge(transaction)

        guard model.shouldBeSaved else {
            Logger.warn("Skipping delete of \(Model.self).")
            return
        }

        model.anyWillRemove(transaction: transaction)

        removeModelFromDatabase(model, transaction: transaction)

        model.anyDidRemove(transaction: transaction)
    }

    private func removeModelFromDatabase<Model: SDSCodableModel>(
        _ model: Model,
        transaction: DBWriteTransaction
    ) {
        do {
            let sql: String = """
                DELETE FROM \(Model.databaseTableName.quotedDatabaseIdentifier)
                WHERE uniqueId = ?
            """

            let statement = try transaction.database.cachedStatement(sql: sql)
            try statement.setArguments([model.uniqueId])
            try statement.execute()
        } catch let error {
            DatabaseCorruptionState.flagDatabaseCorruptionIfNecessary(
                userDefaults: CurrentAppContext().appUserDefaults(),
                error: error
            )

            owsFail("Delete failed: \(error.grdbErrorForLogging)")
        }
    }
}
