//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

protocol ImageEditorTransformable: ImageEditorItem {
    var unitCenter: ImageEditorSample { get }
    var scaling: CGFloat { get }
    var rotationRadians: CGFloat { get }
    func copy(unitCenter: CGPoint) -> Self
    func copy(scaling: CGFloat, rotationRadians: CGFloat) -> Self
}
