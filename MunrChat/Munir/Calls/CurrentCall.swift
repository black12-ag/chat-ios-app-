//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibSignalClient
import MunirServiceKit

struct CurrentCall {
    private let rawValue: AtomicValue<MunirCall?>

    init(rawValue: AtomicValue<MunirCall?>) {
        self.rawValue = rawValue
    }

    func get() -> MunirCall? { rawValue.get() }
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
