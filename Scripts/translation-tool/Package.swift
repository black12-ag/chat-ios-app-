// swift-tools-version: 5.6
//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

import PackageDescription

let package = Package(
    name: "translation-tool",
    platforms: [.macOS(.v12)],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "translation-tool",
            dependencies: [],
            path: "src"
        )
    ]
)
