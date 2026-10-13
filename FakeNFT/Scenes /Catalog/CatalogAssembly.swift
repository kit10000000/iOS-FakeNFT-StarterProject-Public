//
//  CatalogAssembly.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 12.10.2026.
//

import UIKit

final class CatalogAssembly {
    
    private let servicesAssembly: ServicesAssembly

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    func build() -> UIViewController {
        let presenter = CatalogPresenter()
        let viewController = CatalogViewController(presenter: presenter, servicesAssembly: servicesAssembly)
        presenter.view = viewController
        return viewController
    }
}
