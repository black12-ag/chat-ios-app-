//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

public protocol OWSMunrChatServiceProtocol: AnyObject {
    func warmCaches()

    // MARK: - Censorship Circumvention

    var isCensorshipCircumventionActive: Bool { get }
    var hasCensoredPhoneNumber: Bool { get }
    var isCensorshipCircumventionManuallyActivated: Bool { get set }
    var isCensorshipCircumventionManuallyDisabled: Bool { get set }
    var manualCensorshipCircumventionCountryCode: String? { get set }

    func updateHasCensoredPhoneNumberDuringProvisioning(_ e164: E164)
    func resetHasCensoredPhoneNumberFromProvisioning()

    func buildUrlEndpoint(for MunrChatServiceInfo: MunrChatServiceInfo) -> OWSURLSessionEndpoint
    func buildUrlSession(
        for MunrChatServiceInfo: MunrChatServiceInfo,
        endpoint: OWSURLSessionEndpoint,
        configuration: URLSessionConfiguration?,
        maxResponseSize: Int?
    ) -> OWSURLSessionProtocol

    func sharedUrlSessionForCdn(
        cdnNumber: UInt32,
        maxResponseSize: UInt?
    ) async -> OWSURLSessionProtocol
}

public enum MunrChatServiceType {
    case mainMunrChatServiceIdentified
    case mainMunrChatServiceUnidentified
    case storageService
    case updates
    case updates2
    case svr2
}

// MARK: -

public extension OWSMunrChatServiceProtocol {

    private func buildUrlSession(
        for MunrChatServiceType: MunrChatServiceType,
        configuration: URLSessionConfiguration? = nil,
        maxResponseSize: Int? = nil
    ) -> OWSURLSessionProtocol {
        let MunrChatServiceInfo = MunrChatServiceType.MunrChatServiceInfo()
        return buildUrlSession(
            for: MunrChatServiceInfo,
            endpoint: buildUrlEndpoint(for: MunrChatServiceInfo),
            configuration: configuration,
            maxResponseSize: maxResponseSize
        )
    }

    func urlSessionForMainMunrChatService() -> OWSURLSessionProtocol {
        buildUrlSession(for: .mainMunrChatServiceIdentified)
    }

    func urlSessionForStorageService() -> OWSURLSessionProtocol {
        buildUrlSession(for: .storageService)
    }

    func urlSessionForUpdates() -> OWSURLSessionProtocol {
        buildUrlSession(for: .updates)
    }

    func urlSessionForUpdates2() -> OWSURLSessionProtocol {
        buildUrlSession(for: .updates2)
    }
}

// MARK: - Service type mapping

public struct MunrChatServiceInfo {
    let baseUrl: URL
    let censorshipCircumventionSupported: Bool
    let censorshipCircumventionPathPrefix: String
    let shouldUseMunrChatCertificate: Bool
    let shouldHandleRemoteDeprecation: Bool
    let type: MunrChatServiceType
}

extension MunrChatServiceType {

    public func MunrChatServiceInfo() -> MunrChatServiceInfo {
        switch self {
        case .mainMunrChatServiceIdentified:
            return MunrChatServiceInfo(
                baseUrl: URL(string: TSConstants.mainServiceIdentifiedURL)!,
                censorshipCircumventionSupported: true,
                censorshipCircumventionPathPrefix: TSConstants.serviceCensorshipPrefix,
                shouldUseMunrChatCertificate: true,
                shouldHandleRemoteDeprecation: true,
                type: self
            )
        case .mainMunrChatServiceUnidentified:
            return MunrChatServiceInfo(
                baseUrl: URL(string: TSConstants.mainServiceUnidentifiedURL)!,
                censorshipCircumventionSupported: true,
                censorshipCircumventionPathPrefix: TSConstants.serviceCensorshipPrefix,
                shouldUseMunrChatCertificate: true,
                shouldHandleRemoteDeprecation: true,
                type: self
            )
        case .storageService:
            return MunrChatServiceInfo(
                baseUrl: URL(string: TSConstants.storageServiceURL)!,
                censorshipCircumventionSupported: true,
                censorshipCircumventionPathPrefix: TSConstants.storageServiceCensorshipPrefix,
                shouldUseMunrChatCertificate: true,
                shouldHandleRemoteDeprecation: true,
                type: self
            )
        case .updates:
            return MunrChatServiceInfo(
                baseUrl: URL(string: TSConstants.updatesURL)!,
                censorshipCircumventionSupported: false,
                censorshipCircumventionPathPrefix: "unimplemented",
                shouldUseMunrChatCertificate: false,
                shouldHandleRemoteDeprecation: false,
                type: self
            )
        case .updates2:
            return MunrChatServiceInfo(
                baseUrl: URL(string: TSConstants.updates2URL)!,
                censorshipCircumventionSupported: false,
                censorshipCircumventionPathPrefix: "unimplemented", // BADGES TODO
                shouldUseMunrChatCertificate: true,
                shouldHandleRemoteDeprecation: false,
                type: self
            )
        case .svr2:
            return MunrChatServiceInfo(
                baseUrl: URL(string: TSConstants.svr2URL)!,
                censorshipCircumventionSupported: true,
                censorshipCircumventionPathPrefix: TSConstants.svr2CensorshipPrefix,
                shouldUseMunrChatCertificate: true,
                shouldHandleRemoteDeprecation: false,
                type: self
            )
        }
    }
}
