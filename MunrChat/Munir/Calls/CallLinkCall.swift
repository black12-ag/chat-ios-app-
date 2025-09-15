//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import SignalRingRTC
import MunirServiceKit
import MunirUI

final class CallLinkCall: Signal.GroupCall {
    let callLink: CallLink
    let adminPasskey: Data?
    let callLinkState: MunirServiceKit.CallLinkState

    init(
        callLink: CallLink,
        adminPasskey: Data?,
        callLinkState: MunirServiceKit.CallLinkState,
        ringRtcCall: SignalRingRTC.GroupCall,
        videoCaptureController: VideoCaptureController
    ) {
        self.callLink = callLink
        self.adminPasskey = adminPasskey
        self.callLinkState = callLinkState
        super.init(
            audioDescription: "[MunirCall] Call link call",
            ringRtcCall: ringRtcCall,
            videoCaptureController: videoCaptureController
        )
    }

    var mayNeedToAskToJoin: Bool {
        return callLinkState.requiresAdminApproval && adminPasskey == nil
    }
}
