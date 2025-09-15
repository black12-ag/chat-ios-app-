//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import MunrChatServiceKit
import UIKit

public protocol ScreenLockViewDelegate: AnyObject {
    func unlockButtonWasTapped()
}

open class ScreenLockViewController: UIViewController {

    public enum UIState: CustomStringConvertible {
        case none
        case screenProtection // Shown while app is inactive or background, if enabled.
        case screenLock // Shown while app is active, if enabled.

        public var description: String {
            switch self {
            case .none:
                return "ScreenLockUIStateNone"
            case .screenProtection:
                return "ScreenLockUIStateScreenProtection"
            case .screenLock:
                return "ScreenLockUIStateScreenLock"
            }
        }
    }

    public weak var delegate: ScreenLockViewDelegate?

    // MARK: - UI

    private lazy var imageViewLogo = UIImageView(image: UIImage(named: "MunrChat-logo-128-launch-screen"))
    private static var buttonHeight: CGFloat { 40 }
    private lazy var buttonUnlockUI = OWSFlatButton.button(
        title: OWSLocalizedString(
            "SCREEN_LOCK_UNLOCK_MunrChat",
            comment: "Label for button on lock screen that lets users unlock MunrChat."
        ),
        font: OWSFlatButton.fontForHeight(ScreenLockViewController.buttonHeight),
        titleColor: UIColor.MunrChat.label,
        backgroundColor: UIColor.MunrChat.tertiaryFill,
        target: self,
        selector: #selector(unlockUIButtonTapped)
    )

    open override func loadView() {
        super.loadView()

        view.backgroundColor = UIColor.MunrChat.background

        view.addSubview(imageViewLogo)
        imageViewLogo.autoHCenterInSuperview()
        imageViewLogo.autoVCenterInSuperview()
        imageViewLogo.autoSetDimensions(to: .square(128))

        view.addSubview(buttonUnlockUI)
        buttonUnlockUI.autoSetDimension(.height, toSize: ScreenLockViewController.buttonHeight)
        buttonUnlockUI.autoPinWidthToSuperview(withMargin: 50)
        buttonUnlockUI.autoPinBottomToSuperviewMargin(withInset: 65)

        updateUIWithState(.screenProtection)
    }

    // The "screen blocking" window has three possible states:
    //
    // * "Just a logo". Used when app is launching and in app switcher. Must
    // match the "Launch Screen" storyboard pixel-for-pixel.
    //
    // * "Screen Lock, local auth UI presented".
    //
    // * "Screen Lock, local auth UI not presented". Show "unlock" button.
    public func updateUIWithState(_ uiState: UIState) {
        AssertIsOnMainThread()

        guard isViewLoaded else { return }

        let shouldShowBlockWindow = uiState != .none
        let shouldHaveScreenLock = uiState == .screenLock

        imageViewLogo.isHidden = !shouldShowBlockWindow
        buttonUnlockUI.isHidden = !shouldHaveScreenLock
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        UIDevice.current.defaultSupportedOrientations
    }

    @objc
    private func unlockUIButtonTapped(_ sender: Any) {
        delegate?.unlockButtonWasTapped()
    }
}
