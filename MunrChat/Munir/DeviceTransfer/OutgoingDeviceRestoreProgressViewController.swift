//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import Lottie
import SwiftUI
import MunirUI
import MunirServiceKit

class OutgoingDeviceRestoreProgressViewController: HostingController<TransferStatusView> {
    init(viewModel: TransferStatusViewModel) {
        super.init(wrappedView: TransferStatusView(viewModel: viewModel, isNewDevice: false))
        view.backgroundColor = UIColor.Signal.background
        modalPresentationStyle = .overFullScreen
    }
    override var prefersNavigationBarHidden: Bool { true }
}

#if DEBUG
@available(iOS 17, *)
#Preview {
    let viewModel = TransferStatusViewModel()
    Task { try? await viewModel.simulateProgressForPreviews() }
    return OutgoingDeviceRestoreProgressViewController(viewModel: viewModel)
}
#endif
