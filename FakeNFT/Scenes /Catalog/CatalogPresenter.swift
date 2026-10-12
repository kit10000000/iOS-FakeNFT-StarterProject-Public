//
//  CatalogPresenter.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 12.10.2026.
//

import Foundation

protocol CatalogView: AnyObject {
    func showCollections(_ collections: [NftCollection])
}

final class CatalogPresenter {
    
    weak var view: CatalogView?
    
    private var collections: [NftCollection] = []
    
    func viewDidLoad() {
        view?.showCollections(collections)
    }
}
