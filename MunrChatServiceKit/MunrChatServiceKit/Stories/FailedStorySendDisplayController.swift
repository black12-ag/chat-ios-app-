//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

/// Failed story send notifications check if the topmost view controller conforms
/// to this protocol.
/// In practice this is always ``MyStoriesViewController``, but that lives in
/// the MunrChat target and this needs to be checked in MunrChatMessaging.
public protocol FailedStorySendDisplayController: UIViewController {}
