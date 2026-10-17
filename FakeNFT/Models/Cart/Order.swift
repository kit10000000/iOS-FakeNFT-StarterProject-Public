//
//  Order.swift
//  FakeNFT
//
//  Created by Ekaterina on 12.10.2026.
//

import Foundation

struct Order: Decodable {
    let id: String
    let nfts: [String]
}
