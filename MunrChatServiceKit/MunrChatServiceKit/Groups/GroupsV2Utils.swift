//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import LibMunrChatClient

public extension ProfileKeyVersion {
    // GroupsV2 TODO: We might move this to the wrappers.
    func asHexadecimalString() throws -> String {
        let profileKeyVersionData = serialize()
        // A peculiarity of ProfileKeyVersion is that its contents
        // are an ASCII-encoded hexadecimal string of the profile key
        // version, rather than the raw version bytes.
        guard let profileKeyVersionString = String(data: profileKeyVersionData, encoding: .ascii) else {
            throw OWSAssertionError("Invalid profile key version.")
        }
        return profileKeyVersionString
    }
}
