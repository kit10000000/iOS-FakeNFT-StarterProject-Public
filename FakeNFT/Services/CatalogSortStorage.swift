//
//  CatalogSortStorage.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 22.10.2026.
//

import Foundation

enum CatalogSort: String {
    case byName
    case byNftCount
}

protocol CatalogSortStorage: AnyObject {
    var sort: CatalogSort { get set }
}

final class CatalogSortStorageImpl: CatalogSortStorage {

    private let key = "catalog.sort"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var sort: CatalogSort {
        get {
            guard let raw = defaults.string(forKey: key), let stored = CatalogSort(rawValue: raw) else {
                return .byNftCount
            }
            return stored
        }
        set {
            defaults.set(newValue.rawValue, forKey: key)
        }
    }
}
