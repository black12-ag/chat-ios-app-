//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest

@testable import MunrChatServiceKit

final class CooperativeTimeoutTest: XCTestCase {
    func testResolved() async throws {
        try await withCooperativeTimeout(
            seconds: .day,
            operation: {}
        )
    }

    func testTimeout() async throws {
        do {
            try await withCooperativeTimeout(
                seconds: 0,
                operation: { try await Task.sleep(nanoseconds: 1_000_000 * NSEC_PER_SEC) }
            )
            throw OWSGenericError("")
        } catch is CooperativeTimeoutError {
            // this is fine
        }
    }

    func testAlreadyCanceled() async throws {
        let cancellableTask = Task {
            while !Task.isCancelled { await Task.yield() }
            try await withCooperativeTimeout(
                seconds: .day,
                operation: { try await Task.sleep(nanoseconds: 1_000_000 * NSEC_PER_SEC) }
            )
        }
        cancellableTask.cancel()
        do {
            try await cancellableTask.value
            throw OWSGenericError("")
        } catch is CancellationError {
            // this is fine
        }
    }
}
