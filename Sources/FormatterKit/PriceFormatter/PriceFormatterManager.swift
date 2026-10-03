//
//  PriceFormatterManager.swift
//  FormatterKit
//
//  Created by Yann Bonafons on 02/10/2026.
//

import Foundation

// MARK: - PriceFormatterManaging

public protocol PriceFormatterManaging: AnyObject {
    /// Convert an price in cents into a formatted price string with a given format
    func string(priceInCents: Int, using type: any PriceFormatTypeProtocol) -> String
    /// Clear all Formatters
    func clearCache()
}

public final class PriceFormatterManager: PriceFormatterManaging {

    // MARK: Singleton

    public static let shared = PriceFormatterManager()

    // MARK: Private

    private var cache: [String: NumberFormatter] = [:]
    private let lock = NSLock()
    private var localeResolver: LocaleResolverProtocol = LocaleResolver()

    private init() {}

    // MARK: - Public API

    public func string(priceInCents: Int, using type: any PriceFormatTypeProtocol) -> String {
        commit {
            let number = NSDecimalNumber(decimal: Decimal(priceInCents) / 100)
            return formatter(for: type).string(from: number) ?? number.stringValue
        }
    }

    // MARK: - Cache Management

    public func clearCache() {
        commit {
            cache.removeAll()
        }
    }

    // MARK: - Locking

    private func commit<T>(_ mutation: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return mutation()
    }

    // MARK: - Private Factory

    /// Get a `NumberFormatter` from the cache or create one
    private func formatter(for type: any PriceFormatTypeProtocol) -> NumberFormatter {
        let key = type.getCachedKey(localeIdentifier: localeResolver.resolvedLocale.identifier)
        
        if let cached = cache[key] {
            return cached
        }

        let formatter = makePriceFormatter(for: type)
        cache[key] = formatter
        return formatter
    }

    private func makePriceFormatter(for type: any PriceFormatTypeProtocol) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencyCode = type.currencyCode
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = localeResolver.resolvedLocale
        return formatter
    }
    
    // MARK: - For testing purpose

    func updateLocaleResolver(localeResolver: LocaleResolverProtocol) {
        commit {
            self.localeResolver = localeResolver
        }
    }
}
