//
//  DateFormatterManager.swift
//  DateFormatter
//
//  Created by Yann Bonafons on 10/02/2026.
//

import Foundation

// MARK: - DateFormatterManaging

public protocol DateFormatterManaging: AnyObject {
    /// Convert a date into a String with a given format
    func string(from date: Date, using type: any DateFormatTypeProtocol) -> String
    /// Parse a date from a string with a given format
    func date(from string: String, using type: any DateFormatTypeProtocol) -> Date?
    /// Clear all Formatters
    func clearCache()
}

// MARK: - DateFormatterManager

public final class DateFormatterManager: DateFormatterManaging {

    // MARK: Singleton

    public static let shared = DateFormatterManager()

    // MARK: Private

    private var cache: [String: DateFormatter] = [:]
    private let lock = NSLock()
    private var localeResolver: LocaleResolverProtocol = LocaleResolver()

    private init() {}

    // MARK: - Public API

    public func string(from date: Date, using type: any DateFormatTypeProtocol) -> String {
        commit {
            formatter(for: type).string(from: date)
        }
    }

    public func date(from string: String, using type: any DateFormatTypeProtocol) -> Date? {
        commit {
            formatter(for: type).date(from: string)
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

    /// Get a `DateFormatter` from the cache or create one
    private func formatter(for type: any DateFormatTypeProtocol) -> DateFormatter {
        let key = type.getCachedKey(localeIdentifier: localeResolver.resolvedLocale.identifier)

        if let cached = cache[key] {
            return cached
        }

        let formatter = makeDateFormatter(for: type)
        cache[key] = formatter
        return formatter
    }

    private func makeDateFormatter(for type: any DateFormatTypeProtocol) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = type.formatString
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
