//
//  CatalogAssembly.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 12.10.2026.
//

import UIKit

final class CatalogAssembly {
    
    func build() -> UIViewController {
        let presenter = CatalogPresenter()
        let viewController = CatalogViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}
