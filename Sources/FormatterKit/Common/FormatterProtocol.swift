//
//  FormatterProtocol.swift
//  FormatterKit
//
//  Created by Yann Bonafons on 02/10/2026.
//

import Foundation

public nonisolated protocol FormatterProtocol: Equatable, Sendable {
    var specificKeyPart: String { get }
}

public nonisolated extension FormatterProtocol {
    func getCachedKey(localeIdentifier: String) -> String {
        "\(String(reflecting: type(of: self)))|\(specificKeyPart)|\(localeIdentifier)"
    }
}
