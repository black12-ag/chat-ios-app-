//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import MunrChatUI
import MunrChatServiceKit

protocol HomeTabViewController: UIViewController { }

extension HomeTabViewController {
    var conversationSplitViewController: ConversationSplitViewController? {
        return splitViewController as? ConversationSplitViewController
    }

    func createSettingsBarButtonItem(
        databaseStorage: SDSDatabaseStorage,
        shouldShowUnreadPaymentBadge: Bool = false,
        buildActions: (_ settingsAction: UIAction) -> [UIAction],
        showAppSettings: @escaping () -> Void
    ) -> UIBarButtonItem {
        let settingsAction = UIAction(
            title: CommonStrings.openAppSettingsButton,
            image: Theme.iconImage(.contextMenuSettings),
            handler: { _ in showAppSettings() }
        )

        let contextButton = ContextMenuButton(actions: buildActions(settingsAction))
        contextButton.accessibilityLabel = CommonStrings.openAppSettingsButton

        let sizeClass: ConversationAvatarView.Configuration.SizeClass
        if #available(iOS 26, *), FeatureFlags.iOS26SDKIsAvailable {
            sizeClass = .forty
        } else {
            sizeClass = .twentyEight
        }

        let avatarView = ConversationAvatarView(
            sizeClass: sizeClass,
            localUserDisplayMode: .asUser
        )
        databaseStorage.read { transaction in
            avatarView.update(transaction) { config in
                guard let localIdentifiers = DependenciesBridge.shared.tsAccountManager.localIdentifiers(tx: transaction) else { return }
                config.dataSource = .address(localIdentifiers.aciAddress)
                config.applyConfigurationSynchronously()
            }
        }
        contextButton.addSubview(avatarView)
        avatarView.autoPinEdgesToSuperviewEdges()

        let barButtonView: UIView

        if shouldShowUnreadPaymentBadge {
            let wrapper = UIView.container()
            wrapper.addSubview(contextButton)
            contextButton.autoPinEdgesToSuperviewEdges()
            PaymentsViewUtils.addUnreadBadge(toView: wrapper)
            barButtonView = wrapper
        } else {
            barButtonView = contextButton
        }

        let barButtonItem = UIBarButtonItem(customView: barButtonView)
        barButtonItem.accessibilityLabel = CommonStrings.openAppSettingsButton
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            barButtonItem.hidesSharedBackground = true
        }
#endif
        return barButtonItem
    }
}
