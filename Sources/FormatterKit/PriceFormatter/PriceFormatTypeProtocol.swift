//
//  PriceFormatTypeProtocol.swift
//  FormatterKit
//
//  Created by Yann Bonafons on 02/10/2026.
//

import Foundation

public nonisolated protocol PriceFormatTypeProtocol: FormatterProtocol {
    var currencyCode: String { get }
}

nonisolated extension PriceFormatTypeProtocol {
    var specificKeyPart: String {
        currencyCode
    }
}
