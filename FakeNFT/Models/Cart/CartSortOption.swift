//
//  CartSortOption.swift
//  FakeNFT
//
//  Created by Ekaterina on 18.10.2026.
//

import Foundation

enum CartSortOption: String {
    case price, rating, name

    var title: String {
        switch self {
        case .price: return NSLocalizedString("Cart.sort.price", comment: "")
        case .rating: return NSLocalizedString("Cart.sort.rating", comment: "")
        case .name: return NSLocalizedString("Cart.sort.name", comment: "")

        }
    }
}
