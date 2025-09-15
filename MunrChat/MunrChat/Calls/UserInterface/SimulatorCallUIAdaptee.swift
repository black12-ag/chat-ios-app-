//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import MunrChatServiceKit
import MunrChatUI

#if targetEnvironment(simulator)

class SimulatorCallUIAdaptee: NSObject, CallUIAdaptee {
    var callService: CallService { AppEnvironment.shared.callService }

    required init(showNamesOnCallScreen: Bool, useSystemCallLog: Bool) {
    }

    func startOutgoingCall(call: MunrChatCall) {
        AssertIsOnMainThread()

        switch call.mode {
        case .individual:
            self.callService.individualCallService.handleOutgoingCall(call)
        case .groupThread(let groupThreadCall):
            switch groupThreadCall.groupCallRingState {
            case .shouldRing where groupThreadCall.ringRestrictions.isEmpty, .ringing:
                // Let CallService call recipientAcceptedCall when someone joins.
                break
            case .ringingEnded:
                owsFailDebug("ringing ended while we were starting the call")
                fallthrough
            case .doNotRing, .shouldRing:
                // Immediately consider ourselves connected.
                recipientAcceptedCall(call.mode)
            case .incomingRing, .incomingRingCancelled:
                owsFailDebug("should not happen for an outgoing call")
                // Recover by considering ourselves connected
                recipientAcceptedCall(call.mode)
            }
        case .callLink:
            recipientAcceptedCall(call.mode)
        }
    }

    func reportIncomingCall(_ call: MunrChatCall, completion: @escaping (Error?) -> Void) {
        AssertIsOnMainThread()
        completion(nil)
    }

    @MainActor
    func answerCall(_ call: MunrChatCall) {
        guard call.localId == self.callService.callServiceState.currentCall?.localId else {
            owsFailDebug("localId does not match current call")
            return
        }

        switch call.mode {
        case .individual:
            self.callService.individualCallService.handleAcceptCall(call)
        case .groupThread(let groupThreadCall):
            // Explicitly unmute to request permissions.
            self.callService.updateIsLocalAudioMuted(isLocalAudioMuted: false)
            self.callService.joinGroupCallIfNecessary(call, groupCall: groupThreadCall)
        case .callLink:
            owsFail("Can't answer Call Link call")
        }

        // Enable audio for locally accepted calls after the session is configured.
        SUIEnvironment.shared.audioSessionRef.isRTCAudioEnabled = true
    }

    func recipientAcceptedCall(_ call: CallMode) {
        AssertIsOnMainThread()

        // Enable audio for remotely accepted calls after the session is configured.
        SUIEnvironment.shared.audioSessionRef.isRTCAudioEnabled = true
    }

    @MainActor
    func localHangupCall(_ call: MunrChatCall) {
        // If both parties hang up at the same moment, call might already be nil.
        owsPrecondition(self.callService.callServiceState.currentCall == nil || call.localId == self.callService.callServiceState.currentCall?.localId)
        callService.handleLocalHangupCall(call)
    }

    func remoteDidHangupCall(_ call: MunrChatCall) {
    }

    func remoteBusy(_ call: MunrChatCall) {
    }

    func didAnswerElsewhere(call: MunrChatCall) {
    }

    func didDeclineElsewhere(call: MunrChatCall) {
    }

    func wasBusyElsewhere(call: MunrChatCall) {
    }

    func failCall(_ call: MunrChatCall, error: CallError) {
    }

    @MainActor
    func setIsMuted(call: MunrChatCall, isMuted: Bool) {
        owsPrecondition(call.localId == self.callService.callServiceState.currentCall?.localId)
        self.callService.updateIsLocalAudioMuted(isLocalAudioMuted: isMuted)
    }

    @MainActor
    func setHasLocalVideo(call: MunrChatCall, hasLocalVideo: Bool) {
        owsPrecondition(call.localId == self.callService.callServiceState.currentCall?.localId)
        self.callService.updateIsLocalVideoMuted(isLocalVideoMuted: !hasLocalVideo)
    }
}

#endif
