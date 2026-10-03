//
//  DateFormatType.swift
//  DateFormatter
//
//  Created by Yann Bonafons on 10/02/2026.
//

import Foundation

public nonisolated protocol DateFormatTypeProtocol: FormatterProtocol {
    var formatString: String { get }
}

nonisolated extension DateFormatTypeProtocol {
    var specificKeyPart: String {
        formatString
    }
}

// MARK: - DateFormatType

nonisolated enum DateFormatType: DateFormatTypeProtocol {
    /// "yyyy-MM-dd'T'HH:mm:ssZ"
    case iso8601
    /// "dd/MM/yyyy"
    case shortDate
    /// "dd MMMM yyyy"
    case longDate
    /// "HH:mm"
    case shortTime
    /// "dd/MM/yyyy HH:mm"
    case fullDateTime
    /// "dd MMM"
    case dayMonth
    /// "MMMM yyyy"
    case monthYear
    /// Put a custom format
    case custom(String)

    var formatString: String {
        switch self {
        case .iso8601:
            "yyyy-MM-dd'T'HH:mm:ssZ"
        case .shortDate:
            "dd/MM/yyyy"
        case .longDate:
            "dd MMMM yyyy"
        case .shortTime:
            "HH:mm"
        case .fullDateTime:
            "dd/MM/yyyy HH:mm"
        case .dayMonth:
            "dd MMM"
        case .monthYear:
            "MMMM yyyy"
        case .custom(let customFormat):
            customFormat
        }
    }
}
