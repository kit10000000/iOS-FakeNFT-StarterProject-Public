//
//  OrderRequest.swift
//  FakeNFT
//
//  Created by Ekaterina on 12.10.2026.
//

import Foundation

struct OrderRequest: NetworkRequest {
    let id: String
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/\(id)")
    }
    var dto: Dto?
}
