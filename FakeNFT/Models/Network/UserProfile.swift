//
//  UserProfile.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 19.10.2026.
//

import Foundation

struct UserProfile: Decodable {
    let name: String
    let avatar: String
    let description: String
    let website: String
    let nfts: [String]
    let likes: [String]
    let id: String

    init(
        name: String,
        avatar: String,
        description: String,
        website: String,
        nfts: [String],
        likes: [String],
        id: String
    ) {
        self.name = name
        self.avatar = avatar
        self.description = description
        self.website = website
        self.nfts = nfts
        self.likes = likes
        self.id = id
    }

    private enum CodingKeys: String, CodingKey {
        case name, avatar, description, website, nfts, likes, id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        avatar = try container.decode(String.self, forKey: .avatar)
        description = try container.decode(String.self, forKey: .description)
        website = try container.decode(String.self, forKey: .website)
        nfts = try container.decode([String].self, forKey: .nfts)
        likes = try container.decode([String].self, forKey: .likes)
        if let stringId = try? container.decode(String.self, forKey: .id) {
            id = stringId
        } else if let intId = try? container.decode(Int.self, forKey: .id) {
            id = String(intId)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "Profile id is missing")
        }
    }
}
