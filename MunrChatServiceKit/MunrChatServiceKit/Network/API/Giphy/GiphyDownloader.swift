//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public class GiphyDownloader: ProxiedContentDownloader {

    // MARK: - Properties

    public static let giphyDownloader = GiphyDownloader(downloadFolderName: "GIFs")
}
