//
// Copyright 2025 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

extension Optional {

    public func mapAsync<T>(_ fn: (Wrapped) async throws -> T) async rethrows -> T? {
        switch self {
        case .none:
            return nil
        case .some(let v):
            return try await fn(v)
        }
    }
}
