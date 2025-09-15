//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import MunirServiceKit
import MunirUI

class BackupConfirmKeyViewController: EnterAccountEntropyPoolViewController {
    private let aep: AccountEntropyPool

    init(
        aep: AccountEntropyPool,
        onContinue: @escaping () -> Void,
        onSeeKeyAgain: @escaping () -> Void,
    ) {
        self.aep = aep

        super.init()

        configure(
            aepValidationPolicy: .acceptOnly(aep),
            colorConfig: ColorConfig(
                background: UIColor.Signal.groupedBackground,
                aepEntryBackground: UIColor.Signal.secondaryGroupedBackground,
            ),
            headerStrings: HeaderStrings(
                title: OWSLocalizedString(
                    "BACKUP_ONBOARDING_CONFIRM_KEY_TITLE",
                    comment: "Title for a view asking users to confirm their 'Backup Key'."
                ),
                subtitle: OWSLocalizedString(
                    "BACKUP_ONBOARDING_CONFIRM_KEY_SUBTITLE",
                    comment: "Subtitle for a view asking users to confirm their 'Backup Key'."
                )
            ),
            footerButtonConfig: FooterButtonConfig(
                title: BackupKeepKeySafeSheet.seeKeyAgainButtonTitle,
                action: {
                    onSeeKeyAgain()
                }
            ),
            onEntryConfirmed: { [weak self] aep in
                guard let self else { return }

                present(
                    BackupKeepKeySafeSheet(
                        onContinue: onContinue,
                        onSeeKeyAgain: onSeeKeyAgain
                    ),
                    animated: true
                )
            }
        )
    }
}

// MARK: -

#if DEBUG

@available(iOS 17, *)
#Preview {
    let aep = try! AccountEntropyPool(key: String(
        repeating: "a",
        count: AccountEntropyPool.Constants.byteLength
    ))

    return UINavigationController(
        rootViewController: BackupConfirmKeyViewController(
            aep: aep,
            onContinue: { print("Continuing...!") },
            onSeeKeyAgain: { print("Seeing key again...!") }
        )
    )
}

#endif
