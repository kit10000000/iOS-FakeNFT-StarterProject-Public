//
//  CollectionPresenter.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 13.10.2026.
//

import Foundation

protocol CollectionView: AnyObject {
    func showCollection(_ collection: NftCollection)
}

final class CollectionPresenter {
    
    weak var view: CollectionView?
    private let collection: NftCollection
    
    init(collection: NftCollection) {
        self.collection = collection
    }
    
    func viewDidLoad() {
        view?.showCollection(collection)
    }
}
