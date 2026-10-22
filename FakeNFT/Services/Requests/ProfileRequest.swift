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

struct ProfileUpdateDto: Dto {
    let name: String
    let avatar: String
    let description: String
    let website: String
    let nfts: [String]
    let likes: [String]

    func asDictionary() -> [String: DtoValueType] {
        [
            "name": .dtoString(name),
            "avatar": .dtoString(avatar),
            "description": .dtoString(description),
            "website": .dtoString(website),
            "nfts": .dtoArray(nfts),
            "likes": .dtoArray(likes)
        ]
    }
}

struct UpdateProfileRequest: NetworkRequest {
    let dto: Dto?

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }

    var httpMethod: HttpMethod { .put }
}
