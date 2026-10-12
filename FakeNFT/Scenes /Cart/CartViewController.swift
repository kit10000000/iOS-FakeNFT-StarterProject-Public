//
//  CartViewController.swift
//  FakeNFT
//
//  Created by Ekaterina on 11.10.2026.
//

import UIKit

final class CartViewController: UIViewController {

    private let servicesAssembly: ServicesAssembly

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        servicesAssembly.orderService.getOrder(id: "1") { result in
            #if DEBUG
            print(result)
            #endif
        }
    }
}
