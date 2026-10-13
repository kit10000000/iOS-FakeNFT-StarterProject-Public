//
//  CollectionPresenter.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 13.10.2026.
//

import Foundation

protocol CollectionView: AnyObject {
    func showCollection(_ collection: NftCollection)
    func openAuthorWebsite(_ url: URL)
    func openNft(with id: String)
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
    
    func didTapAuthor() {
        guard let url = URL(string: collection.author) else { return }
        guard let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else { return }
        view?.openAuthorWebsite(url)
    }
    
    func didSelectNft(at index: Int) {
        guard collection.nfts.indices.contains(index) else { return }
        view?.openNft(with: collection.nfts[index])
    }
    
    func didTapLike(id: String) {
    }

    func didTapCart(id: String) {
    }
}
