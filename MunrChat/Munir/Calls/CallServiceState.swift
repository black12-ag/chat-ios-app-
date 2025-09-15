//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import MunirServiceKit

protocol CallServiceStateObserver: AnyObject {
    /// Fired on the main thread when the current call changes.
    @MainActor
    func didUpdateCall(from oldValue: MunirCall?, to newValue: MunirCall?)
}

protocol CallServiceStateDelegate: AnyObject {
    @MainActor
    func callServiceState(_ callServiceState: CallServiceState, didTerminateCall call: MunirCall)
}

class CallServiceState {
    weak var delegate: CallServiceStateDelegate?

    init(currentCall: AtomicValue<MunirCall?>) {
        self._currentCall = currentCall
    }

    /// Current call *must* be set on the main thread. It may be read off the
    /// main thread if the current call state must be consulted, but other call
    /// state may race (observer state, sleep state, etc.)
    private let _currentCall: AtomicValue<MunirCall?>

    /// Represents the call currently occuring on this device.
    var currentCall: MunirCall? { _currentCall.get() }

    @MainActor
    func setCurrentCall(_ currentCall: MunirCall?) {
        let oldValue = _currentCall.swap(currentCall)

        // Some didUpdateCall observers don't support transitioning directly from
        // one call to another. We don't currently do that, and we almost certainly
        // won't in the future.
        owsAssertDebug(oldValue == nil || currentCall == nil)

        guard currentCall !== oldValue else {
            return
        }

        for observer in self.observers.elements {
            observer.didUpdateCall(from: oldValue, to: currentCall)
        }
    }

    /**
     * Clean up any existing call state and get ready to receive a new call.
     */
    @MainActor
    func terminateCall(_ call: MunirCall) {
        Logger.info("call: \(call as Optional)")

        // If call is for the current call, clear it out first.
        if call === currentCall {
            setCurrentCall(nil)
        }

        delegate?.callServiceState(self, didTerminateCall: call)
    }

    // MARK: - Observers

    private var observers = WeakArray<any CallServiceStateObserver>()

    @MainActor
    func addObserver(_ observer: any CallServiceStateObserver, syncStateImmediately: Bool = false) {
        observers.append(observer)

        if syncStateImmediately {
            // Synchronize observer with current call state
            observer.didUpdateCall(from: nil, to: currentCall)
        }
    }

    // The observer-related methods should be invoked on the main thread.
    func removeObserver(_ observer: any CallServiceStateObserver) {
        AssertIsOnMainThread()
        observers.removeAll { $0 === observer }
    }
}
