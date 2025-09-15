//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public protocol Streamable {

    func remove(from: RunLoop, forMode: RunLoop.Mode)

    func schedule(in: RunLoop, forMode: RunLoop.Mode)

    func close() throws
}
