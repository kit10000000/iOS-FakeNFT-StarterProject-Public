//
//  CartAssembly.swift
//  FakeNFT
//
//  Created by Ekaterina on 12.10.2026.
//

import UIKit

public final class CartAssembly {

    private let servicesAssembler: ServicesAssembly

    init(servicesAssembler: ServicesAssembly) {
        self.servicesAssembler = servicesAssembler
    }

    public func build() -> UIViewController {
        let presenter = CartPresenterImpl(
            orderService: servicesAssembler.orderService,
            nftService: servicesAssembler.nftService
        )
        let viewController = CartViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}
