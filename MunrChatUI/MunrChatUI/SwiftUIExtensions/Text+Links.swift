//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

public import SwiftUI
import MunrChatServiceKit

extension Text {
    /// Appends a tappable link with a custom action to the end of a `Text`.
    /// Includes a leading space.
    public func appendLink(_ title: String, action: @escaping () -> Void) -> some View {
        // Placeholder URL is needed for the link, but it's thrown away in the OpenURLAction
        (self + Text(" [\(title)](https://support.MunrChat.org/)"))
            .tint(.MunrChat.accent)
            .environment(\.openURL, OpenURLAction { _ in
                action()
                return .handled
            })
    }
}

#Preview {
    Text(verbatim: "Description text.")
        .appendLink(CommonStrings.learnMore) {
            print("Learn more")
        }
}
