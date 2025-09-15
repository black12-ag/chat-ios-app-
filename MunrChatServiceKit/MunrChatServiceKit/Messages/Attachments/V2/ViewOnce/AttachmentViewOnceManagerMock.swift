//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

#if TESTABLE_BUILD

open class AttachmentViewOnceManagerMock: AttachmentViewOnceManager {

    public init() {}

    open func prepareViewOnceContentForDisplay(_ message: TSMessage) -> ViewOnceContent? {
        return nil
    }
}

#endif
