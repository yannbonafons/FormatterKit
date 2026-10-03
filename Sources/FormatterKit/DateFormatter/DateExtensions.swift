//
//  DateExtensions.swift
//  FormatterKit
//
//  Created by Yann Bonafons on 05/04/2026.
//

import Foundation

// MARK: - Date Convenience Extensions

public extension Date {
    func string<Format: DateFormatTypeProtocol>(using type: Format) -> String {
        DateFormatterManager.shared.string(from: self, using: type)
    }
}

public extension String {
    func date<Format: DateFormatTypeProtocol>(using type: Format) -> Date? {
        DateFormatterManager.shared.date(from: self, using: type)
    }
}

public extension TimeInterval {
    func string<Format: DateFormatTypeProtocol>(using type: Format) -> String {
        let date = Date(timeIntervalSinceReferenceDate: self)
        return date.string(using: type)
    }
}
