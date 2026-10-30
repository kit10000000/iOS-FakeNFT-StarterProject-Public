//
//  CurrencyRequest.swift
//  FakeNFT
//
//  Created by Ekaterina on 24.10.2026.
//

import Foundation

struct CurrencyRequest: NetworkRequest {
    let id: String
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/currencies/\(id)")
    }
    var dto: Dto?
}
