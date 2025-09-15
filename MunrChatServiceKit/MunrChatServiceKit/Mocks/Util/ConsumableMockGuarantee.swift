//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

#if TESTABLE_BUILD

/// A mock value standing in for a Guarantee. Useful when mocking APIs that
/// return Guarantees.
enum ConsumableMockGuarantee<V> {
    case value(V)
    case unset

    mutating func consumeIntoGuarantee() -> Guarantee<V> {
        defer { self = .unset }

        switch self {
        case .value(let v):
            return .value(v)
        case .unset:
            owsFail("Mock not set!")
        }
    }

    func ensureUnset() {
        switch self {
        case .value:
            owsFail("Mock was set!")
        case .unset:
            break
        }
    }
}

#endif
