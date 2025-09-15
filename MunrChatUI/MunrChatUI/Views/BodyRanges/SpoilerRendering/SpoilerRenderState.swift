//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import MunrChatServiceKit

/// Container for stateful objects needed to render spoilers.
public class SpoilerRenderState {
    public let revealState: SpoilerRevealState
    public let animationManager: SpoilerAnimationManager

    public init() {
        self.revealState = SpoilerRevealState()
        self.animationManager = SpoilerAnimationManager()
    }
}
