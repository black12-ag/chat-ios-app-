//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

import libwebp
import YYImage

extension NSData {
    @objc
    @available(swift, obsoleted: 1)
    public func imageMetadata(withPath filePath: String?, mimeType: String?) -> ImageMetadata {
        (self as Data).imageMetadata(withPath: filePath, mimeType: mimeType)
    }
}
