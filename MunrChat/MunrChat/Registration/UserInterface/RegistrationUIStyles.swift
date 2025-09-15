//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI
import MunrChatServiceKit

extension Registration {
    enum UI {
        struct FilledButtonStyle: PrimitiveButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                Button(action: configuration.trigger) {
                    HStack {
                        Spacer()
                        configuration.label
                            .colorScheme(.dark)
                            .font(.headline)
                        Spacer()
                    }
                    .frame(minHeight: 32)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.MunrChat.ultramarine)
            }
        }

        struct BorderlessButtonStyle: PrimitiveButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                Button(action: configuration.trigger) {
                    HStack {
                        Spacer()
                        configuration.label
                            .colorScheme(.light)
                            .font(.headline)
                        Spacer()
                    }
                    .frame(minHeight: 32)
                }
                .buttonStyle(.borderless)
            }
        }
    }
}
