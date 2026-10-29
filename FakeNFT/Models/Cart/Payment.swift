//
//  Payment.swift
//  FakeNFT
//
//  Created by Ekaterina on 24.10.2026.
//

import Foundation

struct Payment: Decodable {
    let id: String
    let orderId: String
    let success: Bool
}
