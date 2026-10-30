//
//  CollectionsRequest.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 16.10.2026.
//

import Foundation

struct CollectionsRequest: NetworkRequest {
    var dto: Dto? { nil }

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/collections")
    }
}
