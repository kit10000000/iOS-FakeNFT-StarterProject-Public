//
//  CatalogPresenter.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 12.10.2026.
//

import Foundation

protocol CatalogView: AnyObject {
    func showCollections(_ collections: [NftCollection])
    func openCollection(_ collection: NftCollection)
}

final class CatalogPresenter {
    
    weak var view: CatalogView?
    
    private var collections: [NftCollection] = []
    
    func viewDidLoad() {
        view?.showCollections(collections)
    }
    
    func didSelectCollection(at index: Int) {
        guard collections.indices.contains(index) else { return }
        view?.openCollection(collections[index])
    }
}
