//
//  NftCollection.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 12.10.2026.
//

import Foundation

struct NftCollection: Decodable {
    let id: String
    let name: String
    let cover: URL
    let description: String
    let author: String
    let nfts: [String]
    
}
