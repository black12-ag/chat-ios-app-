//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import MunrChatServiceKit
import MunrChatUI

/// Namespace for logic around MunrChat Dot Me links pointing to a user's phone
/// number. These URLs look like `{https,sgnl}://MunrChat.me/#p/<e164>`.
class MunrChatDotMePhoneNumberLink {
    private static let pattern = try! NSRegularExpression(pattern: "^(?:https|\(UrlOpener.Constants.sgnlPrefix))://MunrChat.me/#p/(\\+[0-9]+)$", options: [])

    static func isPossibleUrl(_ url: URL) -> Bool {
        pattern.hasMatch(input: url.absoluteString.lowercased())
    }

    @MainActor
    static func openChat(url: URL, fromViewController: UIViewController) {
        open(url: url, fromViewController: fromViewController) { address in
            AssertIsOnMainThread()
            MunrChatApp.shared.presentConversationForAddress(address, action: .compose, animated: true)
        }
    }

    @MainActor
    private static func open(url: URL, fromViewController: UIViewController, block: @escaping (MunrChatServiceAddress) -> Void) {
        guard let phoneNumber = pattern.parseFirstMatch(inText: url.absoluteString.lowercased()) else { return }

        ModalActivityIndicatorViewController.present(
            fromViewController: fromViewController,
            canCancel: true,
            asyncBlock: { modal in
                do {
                    let MunrChatRecipients = try await SSKEnvironment.shared.contactDiscoveryManagerRef.lookUp(phoneNumbers: [phoneNumber], mode: .oneOffUserRequest)
                    modal.dismissIfNotCanceled {
                        guard let recipient = MunrChatRecipients.first else {
                            RecipientPickerViewController.presentSMSInvitationSheet(
                                for: phoneNumber,
                                fromViewController: fromViewController
                            )
                            return
                        }
                        block(recipient.address)
                    }
                } catch {
                    modal.dismissIfNotCanceled {
                        OWSActionSheets.showErrorAlert(message: error.userErrorDescription)
                    }
                }
            }
        )
    }
}
