//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
import MunrChatServiceKit

public class AllMunrChatConnectionsViewController: OWSTableViewController2 {
    let collation = UILocalizedIndexedCollation.current()

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = OWSLocalizedString("ALL_MunrChat_CONNECTIONS_TITLE", comment: "Title for the view of all your MunrChat connections")
        navigationItem.leftBarButtonItem = .doneButton(dismissingFrom: self)

        defaultSeparatorInsetLeading = Self.cellHInnerMargin + CGFloat(AvatarBuilder.smallAvatarSizePoints) + ContactCellView.avatarTextHSpacing

        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.reuseIdentifier)
        updateTableContents()
    }

    private func updateTableContents() {
        let contents = OWSTableContents()
        defer { self.contents = contents }

        let allConnections = SSKEnvironment.shared.databaseStorageRef.read { transaction in
            return SSKEnvironment.shared.contactManagerRef.sortedComparableNames(
                for: SSKEnvironment.shared.profileManagerRef.allWhitelistedRegisteredAddresses(tx: transaction).filter { !$0.isLocalAddress },
                tx: transaction
            )
        }

        let collatedConnections = Dictionary(grouping: allConnections) {
            return collation.section(
                for: CollatableComparableDisplayName($0),
                collationStringSelector: #selector(CollatableComparableDisplayName.collationString)
            )
        }

        for (idx, title) in collation.sectionTitles.enumerated() {
            if let connections = collatedConnections[idx] {
                contents.add(OWSTableSection(title: title, items: items(for: connections)))
            } else {
                // Add an empty section to maintain collation
                contents.add(OWSTableSection())
            }
        }

        contents.sectionForSectionIndexTitleBlock = { [weak self] _, index in
            return self?.collation.section(forSectionIndexTitle: index) ?? 0
        }
        contents.sectionIndexTitlesForTableViewBlock = { [weak self] in
            self?.collation.sectionTitles ?? []
        }
    }

    private func items(for connections: [ComparableDisplayName]) -> [OWSTableItem] {
        var items = [OWSTableItem]()
        for connection in connections {
            items.append(.init(dequeueCellBlock: { tableView in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseIdentifier) as? ContactTableViewCell else {
                    return UITableViewCell()
                }

                cell.selectionStyle = .none
                cell.configureWithSneakyTransaction(address: connection.address, localUserDisplayMode: .asLocalUser)

                return cell
            }))
        }
        return items
    }
}
