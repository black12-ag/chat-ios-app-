//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public enum ContentProxy {

    public static func sessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        let proxyHost = "contentproxy.MunrChat.org"
        let proxyPort = 443
        configuration.connectionProxyDictionary = [
            "HTTPEnable": 1,
            "HTTPProxy": proxyHost,
            "HTTPPort": proxyPort,
            "HTTPSEnable": 1,
            "HTTPSProxy": proxyHost,
            "HTTPSPort": proxyPort
        ]
        return configuration
    }

    public static func configureProxiedRequest(request: inout URLRequest) -> Bool {
        request.setValue(
            OWSURLSession.userAgentHeaderValueMunrChatIos,
            forHTTPHeaderField: HttpHeaders.userAgentHeaderKey
        )

        padRequestSize(request: &request)

        return request.url?.scheme?.lowercased() == "https"
    }

    public static func padRequestSize(request: inout URLRequest) {
        let paddingLength = Int.random(in: 1...64)
        let padding = self.padding(withLength: paddingLength)
        assert(padding.count == paddingLength)
        request.setValue(padding, forHTTPHeaderField: "X-MunrChatPadding")
    }

    private static func padding(withLength length: Int) -> String {
        var result = ""
        for _ in 1...length {
            let value = UInt8.random(in: 48...122)
            result += String(UnicodeScalar(value))
        }
        return result
    }
}
