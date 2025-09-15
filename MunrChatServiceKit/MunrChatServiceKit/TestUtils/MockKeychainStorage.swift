//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

#if TESTABLE_BUILD

public class MockKeychainStorage: KeychainStorage {
    private let values = AtomicDictionary<String, Data>([:], lock: .init())

    private func buildKey(service: String, key: String) -> String {
        return "\(service) \(key)"
    }

    public func dataValue(service: String, key: String) throws -> Data {
        if let result = values[buildKey(service: service, key: key)] {
            return result
        } else {
            throw KeychainError.notFound
        }
    }

    public func setDataValue(_ dataValue: Data, service: String, key: String) throws {
        values[buildKey(service: service, key: key)] = dataValue
    }

    public func removeValue(service: String, key: String) throws {
        values[buildKey(service: service, key: key)] = nil
    }
}

#endif
