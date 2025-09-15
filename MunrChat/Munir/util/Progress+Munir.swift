//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

public import Foundation

extension Progress {
    public var remainingUnitCount: Int64 { totalUnitCount - completedUnitCount }
}
