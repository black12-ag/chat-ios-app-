//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

#if TESTABLE_BUILD

public class OWSMunrChatServiceMock: OWSMunrChatServiceProtocol {
    public func warmCaches() {}

    public var isCensorshipCircumventionActive: Bool = false

    public var hasCensoredPhoneNumber: Bool = false

    public var isCensorshipCircumventionManuallyActivated: Bool = false

    public var isCensorshipCircumventionManuallyDisabled: Bool = false

    public var manualCensorshipCircumventionCountryCode: String?

    public func updateHasCensoredPhoneNumberDuringProvisioning(_ e164: E164) {}
    public func resetHasCensoredPhoneNumberFromProvisioning() {}

    public var urlEndpointBuilder: ((MunrChatServiceInfo) -> OWSURLSessionEndpoint)?

    public func buildUrlEndpoint(for MunrChatServiceInfo: MunrChatServiceInfo) -> OWSURLSessionEndpoint {
        return urlEndpointBuilder?(MunrChatServiceInfo) ?? OWSURLSessionEndpoint(
            baseUrl: MunrChatServiceInfo.baseUrl,
            frontingInfo: nil,
            securityPolicy: .systemDefault,
            extraHeaders: [:]
        )
    }

    public var mockUrlSessionBuilder: ((MunrChatServiceInfo, OWSURLSessionEndpoint, URLSessionConfiguration?) -> BaseOWSURLSessionMock)?

    public func buildUrlSession(
        for MunrChatServiceInfo: MunrChatServiceInfo,
        endpoint: OWSURLSessionEndpoint,
        configuration: URLSessionConfiguration?,
        maxResponseSize: Int?
    ) -> OWSURLSessionProtocol {
        return mockUrlSessionBuilder?(MunrChatServiceInfo, endpoint, configuration) ?? BaseOWSURLSessionMock(
            endpoint: endpoint,
            configuration: .default,
            maxResponseSize: maxResponseSize
        )
    }

    public var mockCDNUrlSessionBuilder: ((_ cdnNumber: UInt32) -> BaseOWSURLSessionMock)?

    public func sharedUrlSessionForCdn(
        cdnNumber: UInt32,
        maxResponseSize: UInt?
    ) async -> OWSURLSessionProtocol {
        let baseUrl: URL
        switch cdnNumber {
        case 0:
            baseUrl = URL(string: TSConstants.textSecureCDN0ServerURL)!
        case 3:
            baseUrl = URL(string: TSConstants.textSecureCDN3ServerURL)!
        default:
            baseUrl = URL(string: TSConstants.textSecureCDN2ServerURL)!
        }

        return mockCDNUrlSessionBuilder?(cdnNumber) ?? BaseOWSURLSessionMock(
            endpoint: OWSURLSessionEndpoint(
                baseUrl: baseUrl,
                frontingInfo: nil,
                securityPolicy: .systemDefault,
                extraHeaders: [:]
            ),
            configuration: .default,
            maxResponseSize: maxResponseSize.map(Int.init(clamping:))
        )
    }
}

#endif
