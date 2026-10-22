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

struct CatalogOrderUpdateDto: Dto {
    let nfts: [String]

    func asDictionary() -> [String: DtoValueType] {
        ["nfts": .dtoArray(nfts)]
    }
}

struct UpdateCatalogOrderRequest: NetworkRequest {
    let dto: Dto?

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    var httpMethod: HttpMethod { .put }
}
