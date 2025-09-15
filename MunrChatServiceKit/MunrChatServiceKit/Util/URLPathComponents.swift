//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public struct URLPathComponents: ExpressibleByArrayLiteral, Equatable {
    private static var allowedCharacters: CharacterSet {
        var result = CharacterSet.urlPathAllowed
        result.remove("/")
        return result
    }

    private let pathComponents: [String]

    public init(_ pathComponents: [String]) {
        self.pathComponents = pathComponents
    }

    public init(arrayLiteral: String...) {
        self.pathComponents = arrayLiteral
    }

    public var percentEncoded: String {
        pathComponents
            .compactMap {
                $0.nilIfEmpty?.addingPercentEncoding(withAllowedCharacters: Self.allowedCharacters)
            }
            .joined(separator: "/")
    }
}

// MARK: - URL extension

public extension URL {
    init?(pathComponents: URLPathComponents) {
        self.init(string: pathComponents.percentEncoded)
    }
}
