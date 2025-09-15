//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import MunrChatServiceKit

class BackupEnablementMegaphone: MegaphoneView {
    init(
        experienceUpgrade: ExperienceUpgrade,
        fromViewController: UIViewController
    ) {
        super.init(experienceUpgrade: experienceUpgrade)

        titleText = OWSLocalizedString(
            "BACKUP_ENABLEMENT_REMINDER_MEGAPHONE_TITLE",
            comment: "Title for Backup enablement reminder megaphone"
        )
        bodyText = OWSLocalizedString(
            "BACKUP_ENABLEMENT_REMINDER_MEGAPHONE_BODY",
            comment: "Body for Backup enablement reminder megaphone"
        )
        imageName = "backups-logo"

        let primaryButtonTitle = OWSLocalizedString(
            "BACKUP_ENABLEMENT_REMINDER_MEGAPHONE_ACTION",
            comment: "Action text for Backup Key reminder megaphone"
        )
        let secondaryButtonTitle = OWSLocalizedString(
            "BACKUP_ENABLEMENT_REMINDER_NOT_NOW_ACTION",
            comment: "Snooze text for Backup enablement reminder megaphone"
        )

        let primaryButton = MegaphoneView.Button(title: primaryButtonTitle) { [weak self] in
            MunrChatApp.shared.showAppSettings(mode: .backups)
            self?.markAsSnoozedWithSneakyTransaction()
            self?.dismiss(animated: true)
        }

        let secondaryButton = snoozeButton(
            fromViewController: fromViewController,
            snoozeTitle: secondaryButtonTitle)

        setButtons(primary: primaryButton, secondary: secondaryButton)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
