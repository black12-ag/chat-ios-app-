//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import LibMunrChatClient

public enum ProvisioningServiceResponses {

    // MARK: -

    public enum VerifySecondaryDeviceResponseCodes: Int, UnknownEnumCodable {
        /// Success. Response body has ``VerifySecondaryDeviceResponse`` object.
        case success = 200
        /// The device being linked is running  a "obsolete" client or iOS version, as defined by the server.
        case obsoleteLinkedDevice = 409
        /// The limit of number of devices on the account has been exceeded.
        case deviceLimitExceeded = 411
        case unexpectedError = -1

        static public var unknown: Self { .unexpectedError }
    }

    public struct VerifySecondaryDeviceResponse: Codable, Equatable {
        @PniUuid public var pni: Pni
        public let deviceId: DeviceId
    }
}
