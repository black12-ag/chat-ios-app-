//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import UIKit

class OWSImagePickerController: UIImagePickerController {

    // MARK: Orientation

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.defaultSupportedOrientations
    }
}
