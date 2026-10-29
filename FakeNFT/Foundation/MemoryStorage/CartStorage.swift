//
//  CartStorage.swift
//  FakeNFT
//
//  Created by Ekaterina on 18.10.2026.
//

import Foundation

protocol CartStorageProtocol {
    var sortOption: CartSortOption { get set }
}

final class CartStorage: CartStorageProtocol {

    // MARK: - Properties

    var sortOption: CartSortOption {
        get {
            let raw = UserDefaults.standard.string(forKey: sortOrderKey)
            return CartSortOption(rawValue: raw ?? "") ?? .name
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: sortOrderKey)
        }
    }

    // MARK: - Private Properties

    private let sortOrderKey = "sortOrder"

}
