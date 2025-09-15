//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

/// Used to stub out dates in tests.
///
/// - Important
/// `Date` is not guaranteed to be monotonic. Callers interested in using a
/// `dateProvider` to compute durations should prefer instead a monotonic type.
///
/// - SeeAlso ``DateProviderMonotonic``
/// - SeeAlso ``DurationProvider``
public typealias DateProvider = () -> Date

extension Date {
    public static var provider: DateProvider {
        return { Date() }
    }
}
