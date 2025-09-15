//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

@objc
public class Platform: NSObject {

    @objc
    public static let isSimulator: Bool = {
        let isSim: Bool
        #if targetEnvironment(simulator)
            isSim = true
        #else
            isSim = false
        #endif
        return isSim
    }()
}
