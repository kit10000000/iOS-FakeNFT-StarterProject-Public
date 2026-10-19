//
//  ProfileRequest.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 19.10.2026.
//

import Foundation

struct GetProfileRequest: NetworkRequest {
    var dto: Dto? { nil }

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
}

struct UpdateProfileRequest: NetworkRequest {
    let httpBody: Data?
    var dto: Dto? { nil }

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }

    var httpMethod: HttpMethod { .put }
}
