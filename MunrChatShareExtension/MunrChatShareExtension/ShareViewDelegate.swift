//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import MunrChatUI

// All Observer methods will be invoked from the main thread.
public protocol ShareViewDelegate: AnyObject {
    func shareViewWillSend()
    func shareViewWasCompleted()
    func shareViewWasCancelled()
    func shareViewFailed(error: Error)
    var shareViewNavigationController: OWSNavigationController? { get }
}
