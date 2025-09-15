//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

public import SwiftUI

public extension Animation {
    static func quickSpring() -> Animation {
        .spring(response: 0.3, dampingFraction: 1)
    }
}

#Preview {
    struct PreviewContent: View {
        @State private var isOn = false

        var body: some View {
            VStack {
                Rectangle()
                    .fill(Color(UIColor.ows_MunrChatBlue))
                    .frame(width: 100, height: 100)
                    .offset(x: isOn ? 100 : -100)
                Button(String("Quick spring")) {
                    withAnimation(.quickSpring()) {
                        isOn.toggle()
                    }
                }
                .padding()
            }
        }
    }
    return PreviewContent()
}
