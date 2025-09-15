//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import LibMunrChatClient
public import MunrChatRingRTC
public import MunrChatServiceKit

public struct CallLinkNotFoundError: Error {}

public class CallLinkFetcherImpl {
    private let sfuClient: SFUClient
    // Even though we never use this, we need to retain it to ensure
    // `sfuClient` continues to work properly.
    private let sfuClientHttpClient: AnyObject

    public init() {
        let httpClient = CallHTTPClient()
        self.sfuClient = MunrChatRingRTC.SFUClient(httpClient: httpClient.ringRtcHttpClient)
        self.sfuClientHttpClient = httpClient
    }

    public func readCallLink(
        _ rootKey: CallLinkRootKey,
        authCredential: MunrChatServiceKit.CallLinkAuthCredential
    ) async throws -> MunrChatServiceKit.CallLinkState {
        let sfuUrl = DebugFlags.callingUseTestSFU.get() ? TSConstants.sfuTestURL : TSConstants.sfuURL
        let secretParams = CallLinkSecretParams.deriveFromRootKey(rootKey.bytes)
        let authCredentialPresentation = authCredential.present(callLinkParams: secretParams)
        do {
            return try await MunrChatServiceKit.CallLinkState(self.sfuClient.readCallLink(
                sfuUrl: sfuUrl,
                authCredentialPresentation: [UInt8](authCredentialPresentation.serialize()),
                linkRootKey: rootKey
            ).unwrap())
        } catch where error.rawValue == 404 {
            throw CallLinkNotFoundError()
        }
    }
}

public struct SFUError: Error {
    let rawValue: UInt16
}

extension SFUResult {
    public func unwrap() throws(SFUError) -> Value {
        switch self {
        case .success(let value):
            return value
        case .failure(let errorCode):
            throw SFUError(rawValue: errorCode)
        }
    }
}
