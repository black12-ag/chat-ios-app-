//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public class SwiftSingletons {
    private static let shared = SwiftSingletons()

    private var registeredTypes = Set<ObjectIdentifier>()

    public func register(_ singleton: AnyObject) {
        assert({
            guard !CurrentAppContext().isRunningTests else {
                // Allow multiple registrations while tests are running.
                return true
            }
            let singletonTypeIdentifier = ObjectIdentifier(type(of: singleton))
            let (justAdded, _) = registeredTypes.insert(singletonTypeIdentifier)
            return justAdded
        }(), "Duplicate singleton.")
    }

    public static func register(_ singleton: AnyObject) {
        shared.register(singleton)
    }
}
