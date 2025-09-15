//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibMunrChatClient
import MunrChatServiceKit

struct CurrentCall {
    private let rawValue: AtomicValue<MunrChatCall?>

    init(rawValue: AtomicValue<MunrChatCall?>) {
        self.rawValue = rawValue
    }

    func get() -> MunrChatCall? { rawValue.get() }
}

extension CurrentCall: CurrentCallProvider {
    var hasCurrentCall: Bool { self.get() != nil }
    var currentGroupThreadCallGroupId: GroupIdentifier? {
        switch self.get()?.mode {
        case nil, .individual, .callLink:
            return nil
        case .groupThread(let call):
            return call.groupId
        }
    }
}
