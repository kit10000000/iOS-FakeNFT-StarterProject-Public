//
//  CollectionAssembly.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 13.10.2026.
//

import UIKit

final class CollectionAssembly {
    
    private let servicesAssembly: ServicesAssembly

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    func build(with collection: NftCollection, nfts: [Nft]) -> UIViewController {
        let presenter = CollectionPresenter(collection: collection, nfts: nfts)
        let viewController = CollectionViewController(presenter: presenter, servicesAssembly: servicesAssembly)
        presenter.view = viewController
        return viewController
    }
}
