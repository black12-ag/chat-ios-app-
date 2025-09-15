//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

struct MergePair<T> {
    let fromValue: T
    let intoValue: T

    func map<Result>(_ block: (T) throws -> Result) rethrows -> MergePair<Result> {
        return MergePair<Result>(
            fromValue: try block(fromValue),
            intoValue: try block(intoValue)
        )
    }
}
