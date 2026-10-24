//
//  CurrenciesRequest.swift
//  FakeNFT
//
//  Created by Ekaterina on 24.10.2026.
//

import Foundation

struct CurrenciesRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/currencies")
    }
    var dto: Dto?
}
