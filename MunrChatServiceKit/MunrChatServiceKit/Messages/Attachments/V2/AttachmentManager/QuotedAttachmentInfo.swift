//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public struct QuotedAttachmentInfo {
    public let info: OWSAttachmentInfo
    public let renderingFlag: AttachmentReference.RenderingFlag

    public init(info: OWSAttachmentInfo, renderingFlag: AttachmentReference.RenderingFlag) {
        self.info = info
        self.renderingFlag = renderingFlag
    }
}
