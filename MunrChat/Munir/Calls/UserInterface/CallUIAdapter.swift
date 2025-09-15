//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

public import Foundation
import CallKit
import MunirServiceKit
import MunirUI
import WebRTC
import UIKit

protocol CallUIAdaptee: AnyObject {
    var callService: CallService { get }

    init(showNamesOnCallScreen: Bool, useSystemCallLog: Bool)

    @MainActor
    func startOutgoingCall(call: MunirCall)

    // TODO: It might be nice to prevent call links from being passed here at compile time.
    @MainActor
    func reportIncomingCall(_ call: MunirCall, completion: @escaping (Error?) -> Void)

    @MainActor
    func answerCall(_ call: MunirCall)

    @MainActor
    func recipientAcceptedCall(_ call: CallMode)

    @MainActor
    func localHangupCall(_ call: MunirCall)

    @MainActor
    func remoteDidHangupCall(_ call: MunirCall)

    @MainActor
    func remoteBusy(_ call: MunirCall)

    @MainActor
    func didAnswerElsewhere(call: MunirCall)

    @MainActor
    func didDeclineElsewhere(call: MunirCall)

    @MainActor
    func wasBusyElsewhere(call: MunirCall)

    @MainActor
    func failCall(_ call: MunirCall, error: CallError)

    @MainActor
    func setIsMuted(call: MunirCall, isMuted: Bool)

    @MainActor
    func setHasLocalVideo(call: MunirCall, hasLocalVideo: Bool)
}

/**
 * Notify the user of call related activities.
 * Driven by either a CallKit or System notifications adaptee
 */
public class CallUIAdapter: NSObject {

    private var callService: CallService { AppEnvironment.shared.callService }

    private lazy var adaptee: any CallUIAdaptee = { () -> any CallUIAdaptee in
        let callUIAdapteeType: CallUIAdaptee.Type
#if targetEnvironment(simulator)
        callUIAdapteeType = SimulatorCallUIAdaptee.self
#else
        callUIAdapteeType = CallKitCallUIAdaptee.self
#endif
        let (showNames, useSystemCallLog) = SSKEnvironment.shared.databaseStorageRef.read { tx in
            return (
                SSKEnvironment.shared.preferencesRef.notificationPreviewType(tx: tx) != .noNameNoPreview,
                SSKEnvironment.shared.preferencesRef.isSystemCallLogEnabled(tx: tx)
            )
        }
        return callUIAdapteeType.init(
            showNamesOnCallScreen: showNames,
            useSystemCallLog: useSystemCallLog
        )
    }()

    @MainActor
    public override init() {
        super.init()

        // We cannot assert singleton here, because this class gets rebuilt when the user changes relevant call settings
    }

    @MainActor
    internal func reportIncomingCall(_ call: MunirCall) {
        guard let caller = call.caller else {
            return
        }
        Logger.info("remoteAddress: \(caller)")

        // make sure we don't terminate audio session during call
        _ = SUIEnvironment.shared.audioSessionRef.startAudioActivity(call.commonState.audioActivity)

        adaptee.reportIncomingCall(call) { error in
            AssertIsOnMainThread()

            guard var error = error else {
                self.showCall(call)
                return
            }

            Logger.warn("error: \(error)")

            switch error {
            case CXErrorCodeIncomingCallError.filteredByDoNotDisturb:
                error = CallError.doNotDisturbEnabled
            case CXErrorCodeIncomingCallError.filteredByBlockList:
                error = CallError.contactIsBlocked
            default:
                break
            }

            self.callService.handleFailedCall(failedCall: call, error: error)
        }
    }

    @MainActor
    internal func reportMissedCall(_ call: MunirCall, individualCall: IndividualCall) {
        guard let callerAci = individualCall.thread.contactAddress.aci else {
            owsFailDebug("Can't receive a call without an ACI.")
            return
        }

        let sentAtTimestamp = Date(millisecondsSince1970: individualCall.sentAtTimestamp)
        SSKEnvironment.shared.databaseStorageRef.read { tx in
            SSKEnvironment.shared.notificationPresenterRef.notifyUserOfMissedCall(
                notificationInfo: CallNotificationInfo(
                    groupingId: individualCall.commonState.localId,
                    thread: individualCall.thread,
                    caller: callerAci
                ),
                offerMediaType: individualCall.offerMediaType,
                sentAt: sentAtTimestamp,
                tx: tx
            )
        }
    }

    @MainActor
    internal func startOutgoingCall(call: MunirCall) {
        // make sure we don't terminate audio session during call
        _ = SUIEnvironment.shared.audioSessionRef.startAudioActivity(call.commonState.audioActivity)

        adaptee.startOutgoingCall(call: call)
    }

    @MainActor
    internal func answerCall(_ call: MunirCall) {
        adaptee.answerCall(call)
    }

    @MainActor
    func startAndShowOutgoingCall(thread: TSContactThread, prepareResult: CallStarter.PrepareToStartCallResult, hasLocalVideo: Bool) {
        guard let (call, individualCall) = self.callService.buildOutgoingIndividualCallIfPossible(
            thread: thread,
            localDeviceId: prepareResult.localDeviceId,
            hasVideo: hasLocalVideo
        ) else {
            // @integration This is not unexpected, it could happen if Bob tries
            // to start an outgoing call at the same moment Alice has already
            // sent him an Offer that is being processed.
            Logger.info("found an existing call when trying to start outgoing call: \(thread.contactAddress)")
            return
        }

        startOutgoingCall(call: call)
        individualCall.hasLocalVideo = hasLocalVideo
        self.showCall(call)
    }

    @MainActor
    internal func recipientAcceptedCall(_ call: CallMode) {
        adaptee.recipientAcceptedCall(call)
    }

    @MainActor
    internal func remoteDidHangupCall(_ call: MunirCall) {
        adaptee.remoteDidHangupCall(call)
    }

    @MainActor
    internal func remoteBusy(_ call: MunirCall) {
        adaptee.remoteBusy(call)
    }

    @MainActor
    internal func didAnswerElsewhere(call: MunirCall) {
        adaptee.didAnswerElsewhere(call: call)
    }

    @MainActor
    internal func didDeclineElsewhere(call: MunirCall) {
        adaptee.didDeclineElsewhere(call: call)
    }

    @MainActor
    internal func wasBusyElsewhere(call: MunirCall) {
        adaptee.wasBusyElsewhere(call: call)
    }

    @MainActor
    internal func localHangupCall(_ call: MunirCall) {
        adaptee.localHangupCall(call)
    }

    @MainActor
    internal func failCall(_ call: MunirCall, error: CallError) {
        adaptee.failCall(call, error: error)
    }

    @MainActor
    private func showCall(_ call: MunirCall) {
        guard !call.hasTerminated else {
            Logger.info("Not showing window for terminated call \(call)")
            return
        }

        Logger.info("\(call)")

        let callViewController: UIViewController & CallViewControllerWindowReference
        switch call.mode {
        case .individual(let individualCall):
            callViewController = IndividualCallViewController(call: call, individualCall: individualCall)
        case .groupThread(let groupCall as GroupCall), .callLink(let groupCall as GroupCall):
            callViewController = SSKEnvironment.shared.databaseStorageRef.read { tx in
                return GroupCallViewController.load(call: call, groupCall: groupCall, tx: tx)
            }
        }

        callViewController.modalTransitionStyle = .crossDissolve
        AppEnvironment.shared.windowManagerRef.startCall(viewController: callViewController)
    }

    @MainActor
    internal func setIsMuted(call: MunirCall, isMuted: Bool) {
        // With CallKit, muting is handled by a CXAction, so it must go through the adaptee
        adaptee.setIsMuted(call: call, isMuted: isMuted)
    }

    @MainActor
    internal func setHasLocalVideo(call: MunirCall, hasLocalVideo: Bool) {
        adaptee.setHasLocalVideo(call: call, hasLocalVideo: hasLocalVideo)
    }

    @MainActor
    internal func setCameraSource(call: MunirCall, isUsingFrontCamera: Bool) {
        callService.updateCameraSource(call: call, isUsingFrontCamera: isUsingFrontCamera)
    }
}
