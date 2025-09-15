//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import MunirServiceKit
import MunirUI

#if USE_DEBUG_UI

protocol DebugUIPage {

    var name: String { get }

    func section(thread: TSThread?) -> OWSTableSection?
}

#endif
