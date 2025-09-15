//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import MunrChatServiceKit

struct ProxyConnectionChecker {
    private let chatConnectionManager: any ChatConnectionManager

    init(chatConnectionManager: any ChatConnectionManager) {
        self.chatConnectionManager = chatConnectionManager
    }

    func checkConnection() async -> Bool {
        do {
            try await withCooperativeTimeout(seconds: OWSRequestFactory.textSecureHTTPTimeOut) {
                try await chatConnectionManager.waitForUnidentifiedConnectionToOpen()
            }
            return true
        } catch {
            return false
        }
    }
}
