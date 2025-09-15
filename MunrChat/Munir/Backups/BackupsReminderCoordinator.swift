//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import MunirServiceKit

class BackupsReminderCoordinator {
    private weak var backupKeyReminderNavController: UINavigationController?
    private let accountKeyStore: AccountKeyStore
    private let db: DB
    private let dismissHandler: (Bool) -> Void
    private let fromViewController: UIViewController

    convenience init(fromViewController: UIViewController,
                     dismissHandler: @escaping (Bool) -> Void) {
        self.init(
            fromViewController: fromViewController,
            dismissHandler: dismissHandler,
            accountKeyStore: DependenciesBridge.shared.accountKeyStore,
            db: DependenciesBridge.shared.db,
        )
    }

    init(fromViewController: UIViewController,
         dismissHandler: @escaping (Bool) -> Void,
         accountKeyStore: AccountKeyStore,
         db: DB) {
        self.dismissHandler = dismissHandler
        self.fromViewController = fromViewController
        self.accountKeyStore = accountKeyStore
        self.db = db
    }

    func presentVerifyFlow() {
        let navController = UINavigationController()
        backupKeyReminderNavController = navController
        guard let aep = db.read(block: { accountKeyStore.getAccountEntropyPool(tx: $0) }) else {
            return
        }

        // Retain ourselves as long as the nav controller is presented.
        ObjectRetainer.retainObject(self, forLifetimeOf: navController)

        navController.viewControllers = [
            RegistrationEnterAccountEntropyPoolViewController(
                state: RegistrationEnterAccountEntropyPoolState(canShowBackButton: true),
                presenter: self,
                aepValidationPolicy: .acceptOnly(aep)
            ),
        ]

        fromViewController.present(navController, animated: true)
    }

    private func showRecordBackupKey(
        backupKeyReminderNavController: UINavigationController,
        localDeviceAuthSuccess: LocalDeviceAuthentication.AuthSuccess,
        aep: AccountEntropyPool
    ) {
        backupKeyReminderNavController.pushViewController(
            BackupRecordKeyViewController(
                aepMode: .current(aep, localDeviceAuthSuccess),
                options: [.showContinueButton],
                onCompletion: { [weak self] _ in
                    self?.showConfirmBackupKey(backupKeyReminderNavController: backupKeyReminderNavController, aep: aep)
                },
            ),
            animated: true
        )
    }

    private func showConfirmBackupKey(backupKeyReminderNavController: UINavigationController, aep: AccountEntropyPool) {
        backupKeyReminderNavController.pushViewController(
            BackupConfirmKeyViewController(
                aep: aep,
                onContinue: { [weak self] in
                    self?.dismissHandler(false)
                    backupKeyReminderNavController.dismiss(animated: true)
                },
                onSeeKeyAgain: {
                    backupKeyReminderNavController.popViewController(animated: true)
                }
            ),
            animated: true
        )
    }
}

extension BackupsReminderCoordinator: RegistrationEnterAccountEntropyPoolPresenter {
    func next(accountEntropyPool: AccountEntropyPool) {
        backupKeyReminderNavController?.dismiss(animated: true)
        dismissHandler(true)
    }

    func cancelKeyEntry() {
        backupKeyReminderNavController?.dismiss(animated: true)
    }

    func forgotKeyAction() {
        Task { @MainActor in
            guard
                let authSuccess = await LocalDeviceAuthentication().performBiometricAuth(),
                let backupKeyReminderNavController = backupKeyReminderNavController,
                let aep = db.read(block: { accountKeyStore.getAccountEntropyPool(tx: $0) })
            else { return }

            showRecordBackupKey(
                backupKeyReminderNavController: backupKeyReminderNavController,
                localDeviceAuthSuccess: authSuccess,
                aep: aep
            )
        }
    }
}
