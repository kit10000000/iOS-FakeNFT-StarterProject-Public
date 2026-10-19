//
//  CatalogOrderRequest.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 19.10.2026.
//

import Foundation

struct CatalogOrderResponse: Decodable {
    let nfts: [String]
}

struct GetCatalogOrderRequest: NetworkRequest {
    var dto: Dto? { nil }

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
}

struct UpdateCatalogOrderRequest: NetworkRequest {
    let httpBody: Data?
    var dto: Dto? { nil }

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    var httpMethod: HttpMethod { .put }
}
