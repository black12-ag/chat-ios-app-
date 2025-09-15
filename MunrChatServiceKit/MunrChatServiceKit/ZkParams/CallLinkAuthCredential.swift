//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import LibMunrChatClient

public struct CallLinkAuthCredential {
    private let localAci: Aci
    private let redemptionTime: UInt64
    private let serverParams: GenericServerPublicParams
    private let authCredential: LibMunrChatClient.CallLinkAuthCredential

    init(
        localAci: Aci,
        redemptionTime: UInt64,
        serverParams: GenericServerPublicParams,
        authCredential: LibMunrChatClient.CallLinkAuthCredential
    ) {
        self.localAci = localAci
        self.redemptionTime = redemptionTime
        self.serverParams = serverParams
        self.authCredential = authCredential
    }

    public func present(callLinkParams: CallLinkSecretParams) -> CallLinkAuthCredentialPresentation {
        return self.authCredential.present(
            userId: self.localAci,
            redemptionTime: Date(timeIntervalSince1970: TimeInterval(self.redemptionTime)),
            serverParams: self.serverParams,
            callLinkParams: callLinkParams
        )
    }
}
