//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public enum SMKError: Error {
    case assertionError(description: String)
    case invalidInput(_ description: String)
}
