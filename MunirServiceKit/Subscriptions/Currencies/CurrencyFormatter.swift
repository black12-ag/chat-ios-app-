//
// Copyright 2025 Signal Messenger, LLC
// SPDX-License-Identifier: MIT
//

/// Like `NumberFormatter`, but designed for currency formatting.
public class CurrencyFormatter {
    public static func format(
        money: FiatMoney,
        locale: Locale = .current
    ) -> String {
        let value = money.value
        let currencyCode = money.currencyCode

        let isZeroDecimalCurrency = DonationUtilities.zeroDecimalCurrencyCodes.contains(currencyCode)

        let decimalPlaces: Int
        if isZeroDecimalCurrency {
            decimalPlaces = 0
        } else if value.isInteger {
            decimalPlaces = 0
        } else {
            decimalPlaces = 2
        }

        let formatStyle = Decimal.FormatStyle.Currency(
            code: currencyCode,
            locale: locale
        )
            .precision(.fractionLength(decimalPlaces))

        return formatStyle.format(value)
    }
}
