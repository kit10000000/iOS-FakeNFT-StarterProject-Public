//
//  FormURLEncoder.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 19.10.2026.
//

import Foundation

enum FormURLEncoder {

    private static let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")

    static func encode(_ items: [(String, String)]) -> Data {
        let string = items.map { key, value in
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
            return encodedKey + "=" + encodedValue
        }.joined(separator: "&")
        return Data(string.utf8)
    }
}
