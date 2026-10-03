import Foundation
import Testing
@testable import FormatterKit

// MARK: - Test Doubles

/// Forces a fixed `Locale` so formatting tests don't depend on the host device's settings.
private struct MockLocaleResolver: LocaleResolverProtocol {
    let resolvedLocale: Locale
}

private enum TestPriceFormat: PriceFormatTypeProtocol {
    case usd
    case eur

    var currencyCode: String {
        switch self {
        case .usd: "USD"
        case .eur: "EUR"
        }
    }
}

// MARK: - DateFormatterManager

@Suite(.serialized)
struct DateFormatterManagerTests {

    init() {
        DateFormatterManager.shared.clearCache()
    }

    @Test func formatsLongDateUsingForcedFrenchLocale() throws {
        DateFormatterManager.shared.updateLocaleResolver(localeResolver: MockLocaleResolver(resolvedLocale: Locale(identifier: "fr_FR")))
        defer { DateFormatterManager.shared.updateLocaleResolver(localeResolver: LocaleResolver()) }

        let date = try #require(Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 4, day: 5)))

        #expect(date.string(using: DateFormatType.longDate) == "05 avril 2026")
    }

    @Test func formatsLongDateUsingForcedEnglishLocale() throws {
        DateFormatterManager.shared.updateLocaleResolver(localeResolver: MockLocaleResolver(resolvedLocale: Locale(identifier: "en_US")))
        defer { DateFormatterManager.shared.updateLocaleResolver(localeResolver: LocaleResolver()) }

        let date = try #require(Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 4, day: 5)))

        #expect(date.string(using: DateFormatType.longDate) == "05 April 2026")
    }

    @Test func formatsDateUsingCustomFormat() throws {
        DateFormatterManager.shared.updateLocaleResolver(localeResolver: MockLocaleResolver(resolvedLocale: Locale(identifier: "en_US")))
        defer { DateFormatterManager.shared.updateLocaleResolver(localeResolver: LocaleResolver()) }

        let date = try #require(Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 4, day: 5)))

        #expect(date.string(using: DateFormatType.custom("yyyy/MM/dd")) == "2026/04/05")
    }

    @Test func parsesISO8601StringIntoCorrectInstant() throws {
        DateFormatterManager.shared.updateLocaleResolver(localeResolver: MockLocaleResolver(resolvedLocale: Locale(identifier: "en_US")))
        defer { DateFormatterManager.shared.updateLocaleResolver(localeResolver: LocaleResolver()) }

        let parsedDate = try #require("2026-04-05T10:30:00+0000".date(using: DateFormatType.iso8601))

        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = try #require(TimeZone(identifier: "UTC"))
        let components = utcCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: parsedDate)

        #expect(components.year == 2026)
        #expect(components.month == 4)
        #expect(components.day == 5)
        #expect(components.hour == 10)
        #expect(components.minute == 30)
    }

    @Test func timeIntervalStringUsesForcedLocale() throws {
        DateFormatterManager.shared.updateLocaleResolver(localeResolver: MockLocaleResolver(resolvedLocale: Locale(identifier: "fr_FR")))
        defer { DateFormatterManager.shared.updateLocaleResolver(localeResolver: LocaleResolver()) }

        let date = try #require(Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 4, day: 5)))

        #expect(date.timeIntervalSinceReferenceDate.string(using: DateFormatType.longDate) == "05 avril 2026")
    }

    @Test func clearCacheStillFormatsCorrectlyAfterward() throws {
        DateFormatterManager.shared.updateLocaleResolver(localeResolver: MockLocaleResolver(resolvedLocale: Locale(identifier: "en_US")))
        defer { DateFormatterManager.shared.updateLocaleResolver(localeResolver: LocaleResolver()) }

        let date = try #require(Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 4, day: 5)))
        _ = date.string(using: DateFormatType.shortDate)

        DateFormatterManager.shared.clearCache()

        #expect(date.string(using: DateFormatType.shortDate) == "05/04/2026")
    }
}

// MARK: - PriceFormatterManager

@Suite(.serialized)
struct PriceFormatterManagerTests {

    init() {
        PriceFormatterManager.shared.clearCache()
    }

    @Test func formatsPriceUsingForcedEnglishLocale() {
        PriceFormatterManager.shared.updateLocaleResolver(localeResolver: MockLocaleResolver(resolvedLocale: Locale(identifier: "en_US")))
        defer { PriceFormatterManager.shared.updateLocaleResolver(localeResolver: LocaleResolver()) }

        #expect(1234.price(using: TestPriceFormat.usd) == "$12.34")
    }

    @Test func formatsEURPriceUsingForcedFrenchLocale() {
        PriceFormatterManager.shared.updateLocaleResolver(localeResolver: MockLocaleResolver(resolvedLocale: Locale(identifier: "fr_FR")))
        defer { PriceFormatterManager.shared.updateLocaleResolver(localeResolver: LocaleResolver()) }

        let result = 1234.price(using: TestPriceFormat.eur)

        // `contains` instead of `==`: fr_FR separates the amount and symbol with U+00A0
        // (NO-BREAK SPACE), not a regular space, so a literal "12,34 €" never matches.
        #expect(result.contains("12,34"))
        #expect(result.contains("€"))
    }

    @Test func formatsUSPriceUsingForcedFrenchLocale() {
        PriceFormatterManager.shared.updateLocaleResolver(localeResolver: MockLocaleResolver(resolvedLocale: Locale(identifier: "fr_FR")))
        defer { PriceFormatterManager.shared.updateLocaleResolver(localeResolver: LocaleResolver()) }

        let result = 1234.price(using: TestPriceFormat.usd)

        // Same U+00A0 caveat as above, hence `contains` rather than an exact match.
        #expect(result.contains("12,34"))
        #expect(result.contains("$US"))
    }

    @Test func formatsNegativePriceUsingAccountingStyle() {
        PriceFormatterManager.shared.updateLocaleResolver(localeResolver: MockLocaleResolver(resolvedLocale: Locale(identifier: "en_US")))
        defer { PriceFormatterManager.shared.updateLocaleResolver(localeResolver: LocaleResolver()) }

        #expect((-1234).price(using: TestPriceFormat.usd) == "($12.34)")
    }

    @Test func formatsZeroPrice() {
        PriceFormatterManager.shared.updateLocaleResolver(localeResolver: MockLocaleResolver(resolvedLocale: Locale(identifier: "en_US")))
        defer { PriceFormatterManager.shared.updateLocaleResolver(localeResolver: LocaleResolver()) }

        #expect(0.price(using: TestPriceFormat.usd) == "$0.00")
    }

    @Test func clearCacheStillFormatsCorrectlyAfterward() {
        PriceFormatterManager.shared.updateLocaleResolver(localeResolver: MockLocaleResolver(resolvedLocale: Locale(identifier: "en_US")))
        defer { PriceFormatterManager.shared.updateLocaleResolver(localeResolver: LocaleResolver()) }

        _ = 1234.price(using: TestPriceFormat.usd)

        PriceFormatterManager.shared.clearCache()

        #expect(1234.price(using: TestPriceFormat.usd) == "$12.34")
    }
}
