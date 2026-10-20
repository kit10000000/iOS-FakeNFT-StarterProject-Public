//
//  OrderPutRequest.swift
//  FakeNFT
//
//  Created by Ekaterina on 20.10.2026.
//

import Foundation

struct OrderPutRequest: NetworkRequest {
   var endpoint: URL? {
       URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
   }
   var httpMethod: HttpMethod = .put
   var dto: Dto?
}

struct OrderPutDtoObject: Dto {
   let nfts: [String]

    enum CodingKeys: String, CodingKey {
        case nfts = "nfts"
    }

    func asDictionary() -> [String : DtoValueType] {
        [
            CodingKeys.nfts.rawValue: .dtoArray(nfts)
        ]
    }

}
