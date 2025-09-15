//
// Copyright 2025 Munir, LLC
// SPDX-License-Identifier: MIT
//

import Foundation
public import MunirServiceKit

public protocol PaymentsHistoryItem {

    var displayName: String { get }

    var address: SignalServiceAddress? { get }

    var isIncoming: Bool { get }

    var isOutgoing: Bool { get }

    var isUnidentified: Bool { get }

    var isFailed: Bool { get }

    var isDefragmentation: Bool { get }

    var receiptData: Data? { get }

    var formattedFeeAmount: String? { get }

    var paymentType: TSPaymentType { get }

    var paymentState: TSPaymentState { get }

    var ledgerBlockDate: Date? { get }

    var ledgerBlockIndex: UInt64? { get }

    var isUnread: Bool { get }

    var memoMessage: String? { get }

    var attributedPaymentAmount: NSAttributedString? { get }

    var formattedPaymentAmount: String? { get }

    func statusDescription(isLongForm: Bool) -> String?

    func markAsRead(tx: DBWriteTransaction)

    func reload(tx: DBReadTransaction) -> Self?
}
