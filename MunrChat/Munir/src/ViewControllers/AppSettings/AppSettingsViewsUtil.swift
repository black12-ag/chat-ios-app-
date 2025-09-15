//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

public import MunirUI
import UIKit

public class AppSettingsViewsUtil {
    public class func newCell() -> UITableViewCell {
        let cell = OWSTableItem.newCell()
        cell.selectionStyle = .none
        return cell
    }

    public class func loadingTableItem() -> OWSTableItem {
        OWSTableItem.init(
            customCellBlock: {
                let cell = newCell()

                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.alignment = .center
                stackView.layoutMargins = UIEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
                stackView.isLayoutMarginsRelativeArrangement = true
                cell.contentView.addSubview(stackView)
                stackView.autoPinEdgesToSuperviewEdges()

                let activitySpinner = UIActivityIndicatorView(style: .medium)
                activitySpinner.startAnimating()

                stackView.addArrangedSubview(activitySpinner)

                return cell
            },
            actionBlock: {}
        )
    }
}
