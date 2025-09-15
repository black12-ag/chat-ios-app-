//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation

struct DeviceMessage {
    let type: SSKProtoEnvelopeType
    let destinationDeviceId: DeviceId
    let destinationRegistrationId: UInt32
    let content: Data
}

struct SentDeviceMessage {
    var destinationDeviceId: DeviceId
    var destinationRegistrationId: UInt32
}
