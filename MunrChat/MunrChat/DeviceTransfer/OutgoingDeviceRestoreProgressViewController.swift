//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import Lottie
import SwiftUI
import MunrChatUI
import MunrChatServiceKit

class OutgoingDeviceRestoreProgressViewController: HostingController<TransferStatusView> {
    init(viewModel: TransferStatusViewModel) {
        super.init(wrappedView: TransferStatusView(viewModel: viewModel, isNewDevice: false))
        view.backgroundColor = UIColor.MunrChat.background
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
