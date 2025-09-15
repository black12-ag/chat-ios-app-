//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import MunrChatRingRTC

public class CallHTTPClient {
    public let ringRtcHttpClient: MunrChatRingRTC.HTTPClient

    public init() {
        self.ringRtcHttpClient = MunrChatRingRTC.HTTPClient()
        self.ringRtcHttpClient.delegate = self
    }
}

// MARK: - HTTPDelegate

extension CallHTTPClient: HTTPDelegate {
    /**
     * A HTTP request should be sent to the given url.
     * Invoked on the main thread, asychronously.
     * The result of the call should be indicated by calling the receivedHttpResponse() function.
     */
    public func sendRequest(requestId: UInt32, request: HTTPRequest) {
        AssertIsOnMainThread()

        let session = OWSURLSession(
            securityPolicy: OWSURLSession.MunrChatServiceSecurityPolicy,
            configuration: OWSURLSession.defaultConfigurationWithoutCaching,
            canUseMunrChatProxy: true
        )
        session.require2xxOr3xx = false
        session.allowRedirects = true
        session.customRedirectHandler = { redirectedRequest in
            var redirectedRequest = redirectedRequest
            if let authHeader = request.headers.first(where: {
                $0.key.caseInsensitiveCompare("Authorization") == .orderedSame
            }) {
                redirectedRequest.setValue(authHeader.value, forHTTPHeaderField: authHeader.key)
            }
            return redirectedRequest
        }

        Task { @MainActor in
            do {
                var headers = HttpHeaders()
                headers.addHeaderMap(request.headers, overwriteOnConflict: true)

                let response = try await session.performRequest(
                    request.url,
                    method: request.method.httpMethod,
                    headers: headers,
                    body: request.body
                )
                self.ringRtcHttpClient.receivedResponse(
                    requestId: requestId,
                    response: response.asRingRTCResponse
                )
            } catch {
                if error.isNetworkFailureOrTimeout {
                    Logger.warn("Peek client HTTP request had network error: \(error)")
                } else {
                    owsFailDebug("Peek client HTTP request failed \(error)")
                }
                self.ringRtcHttpClient.httpRequestFailed(requestId: requestId)
            }
        }
    }
}

extension MunrChatRingRTC.HTTPMethod {
    var httpMethod: MunrChatServiceKit.HTTPMethod {
        switch self {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .delete: return .delete
        }
    }
}

extension MunrChatServiceKit.HTTPResponse {
    var asRingRTCResponse: MunrChatRingRTC.HTTPResponse {
        return MunrChatRingRTC.HTTPResponse(
            statusCode: UInt16(responseStatusCode),
            body: responseBodyData
        )
    }
}
