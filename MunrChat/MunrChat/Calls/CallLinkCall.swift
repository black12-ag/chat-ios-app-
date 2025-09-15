//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import MunrChatRingRTC
import MunrChatServiceKit
import MunrChatUI

final class CallLinkCall: MunrChat.GroupCall {
    let callLink: CallLink
    let adminPasskey: Data?
    let callLinkState: MunrChatServiceKit.CallLinkState

    init(
        callLink: CallLink,
        adminPasskey: Data?,
        callLinkState: MunrChatServiceKit.CallLinkState,
        ringRtcCall: MunrChatRingRTC.GroupCall,
        videoCaptureController: VideoCaptureController
    ) {
        self.callLink = callLink
        self.adminPasskey = adminPasskey
        self.callLinkState = callLinkState
        super.init(
            audioDescription: "[MunrChatCall] Call link call",
            ringRtcCall: ringRtcCall,
            videoCaptureController: videoCaptureController
        )
    }

    var mayNeedToAskToJoin: Bool {
        return callLinkState.requiresAdminApproval && adminPasskey == nil
    }
}
