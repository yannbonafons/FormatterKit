//
//  PriceExtensions.swift
//  FormatterKit
//
//  Created by Yann Bonafons on 02/10/2026.
//

public extension Int {
    func price<Format: PriceFormatTypeProtocol>(using type: Format) -> String {
        PriceFormatterManager.shared.string(priceInCents: self, using: type)
    }
}
