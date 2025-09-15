//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest

@testable import MunrChatServiceKit

final class CancellableContinuationTest: XCTestCase {
    func testNestedCancellation() async throws {
        let cancellableTask = Task {
            let cancellableContinuation = CancellableContinuation<Void>()
            try await withTaskCancellationHandler(
                operation: cancellableContinuation.wait,
                onCancel: { /* do nothing */ }
            )
        }
        cancellableTask.cancel()
        do {
            try await cancellableTask.value
            XCTFail("Task must fail.")
        } catch is CancellationError {
            // this is fine
        }
    }
}
