//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public enum StoryContextViewState: Equatable {
    case unviewed
    case viewed
    case noStories

    var hasStoriesToDisplay: Bool {
        switch self {
        case .noStories: return false
        case .viewed, .unviewed: return true
        }
    }
}
