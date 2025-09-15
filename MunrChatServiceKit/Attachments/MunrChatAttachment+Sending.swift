//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

extension MunrChatAttachment {

    public struct ForSending {
        public let dataSource: AttachmentDataSource
        public let isViewOnce: Bool
        public let renderingFlag: AttachmentReference.RenderingFlag

        public init(dataSource: AttachmentDataSource, isViewOnce: Bool, renderingFlag: AttachmentReference.RenderingFlag) {
            self.dataSource = dataSource
            self.isViewOnce = isViewOnce
            self.renderingFlag = renderingFlag
        }
    }

    public func forSending() async throws -> ForSending {
        let dataSource = try await self.buildAttachmentDataSource()
        return .init(
            dataSource: dataSource,
            isViewOnce: self.isViewOnceAttachment,
            renderingFlag: self.renderingFlag
        )
    }
}
