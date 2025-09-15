//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import UIKit
import MunirServiceKit

enum ContextualActionBuilder {
    typealias Handler = (_ completion: @escaping (_ success: Bool) -> Void) -> Void

    static func makeContextualAction(
        style: UIContextualAction.Style,
        color: UIColor,
        image: String,
        title: String,
        handler: @escaping () -> Void
    ) -> UIContextualAction {
        Self.makeContextualAction(
            style: style,
            color: color,
            image: image,
            title: title
        ) { completion in
            handler()
            completion(true)
        }
    }

    static func makeContextualAction(
        style: UIContextualAction.Style,
        color: UIColor,
        image: String,
        title: String,
        handler: @escaping Handler
    ) -> UIContextualAction {
        // We want to always show a title with the icon. iOS 26 does this by
        // default, but previous iOS versions only does when the cell's
        // height > 91, so we generate an image with the text below it.
        if #available(iOS 26, *), FeatureFlags.iOS26SDKIsAvailable {
            let action = UIContextualAction(
                style: style,
                title: title
            ) { _, _, completion in
                handler(completion)
            }
            action.backgroundColor = color
            action.image = UIImage(named: image)
            return action
        } else {
            let action = UIContextualAction(
                style: style,
                title: nil
            ) { _, _, completion in
                handler(completion)
            }
            action.accessibilityLabel = title
            action.backgroundColor = color
            action.image = UIImage(named: image)?.withTitle(
                title,
                font: .dynamicTypeFootnote.medium(),
                color: .ows_white,
                maxTitleWidth: 68,
                minimumScaleFactor: CGFloat(8) / CGFloat(13),
                spacing: 4
            )?.withRenderingMode(.alwaysTemplate)

            return action
        }
    }
}
