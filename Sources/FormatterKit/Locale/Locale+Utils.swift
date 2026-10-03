//
//  Locale+Utils.swift
//  FormatterKit
//
//  Created by Yann Bonafons on 02/10/2026.
//

import Foundation

protocol LocaleResolverProtocol {
    var resolvedLocale: Locale { get }
}

struct LocaleResolver: LocaleResolverProtocol {
    /// Get the local that should be used by formatters
    /// It will use the first user preferred language supported by the app
    nonisolated var resolvedLocale: Locale {
        for preferredLanguage in Locale.preferredLanguages {
            let languageCode = Locale(identifier: preferredLanguage).language.languageCode?.identifier ?? ""
            let supportedLanguage = Bundle.main.localizations
            if supportedLanguage.contains(languageCode) {
                return Locale(identifier: preferredLanguage)
            }
        }
        return Locale(identifier: "en")
    }
}
