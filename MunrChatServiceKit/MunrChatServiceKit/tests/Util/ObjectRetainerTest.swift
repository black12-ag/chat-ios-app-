//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Testing

@testable import MunrChatServiceKit

@Suite
struct ObjectRetainerTest {
    private class Retainer {}
    private class Retained {}

    @Test
    func retainerRetainsObjectUntilRetainerReleased() {
        var retainer: Retainer? = Retainer()
        weak var retained: Retained?

        do {
            let _retained = Retained()
            retained = _retained

            ObjectRetainer.retainObject(
                retained!,
                forLifetimeOf: retainer!
            )
        }

        #expect(retainer != nil)
        #expect(retained != nil)

        retainer = nil

        #expect(retainer == nil)
        #expect(retained == nil)
    }
}
