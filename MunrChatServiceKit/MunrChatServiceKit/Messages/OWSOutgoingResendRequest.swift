//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import LibMunrChatClient

extension OWSOutgoingResendRequest {
    @objc
    open override func buildPlainTextData(_ thread: TSThread, transaction: DBWriteTransaction) -> Data? {
        do {
            let decryptionErrorMessage = try DecryptionErrorMessage(bytes: decryptionErrorData)
            let plaintextContent = PlaintextContent(decryptionErrorMessage)
            return plaintextContent.serialize()
        } catch {
            owsFailDebug("Failed to build plaintext: \(error)")
            return nil
        }
    }
}
