//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import Testing

@testable import MunrChatServiceKit

struct UncooperativeTimeoutTest {
    @Test func resolved() async throws {
        try await withUncooperativeTimeout(seconds: .day, operation: {})
    }

    @Test func timeout() async throws {
        var streamContinuation: AsyncStream<CheckedContinuation<Void, Never>>.Continuation! = nil
        let continuationStream = AsyncStream<CheckedContinuation<Void, Never>> { streamContinuation = $0 }
        await #expect(throws: UncooperativeTimeoutError.self) {
            try await withUncooperativeTimeout(seconds: 0) {
                // suspend forever until the timeout fires
                await withCheckedContinuation {
                    streamContinuation.yield($0)
                    streamContinuation.finish()
                }
            }
        }
        for await cleanupContinuation in continuationStream {
            cleanupContinuation.resume()
        }
    }
}
