//
//  PaymentAssembly.swift
//  FakeNFT
//
//  Created by Ekaterina on 24.10.2026.
//

import UIKit

public final class PaymentAssembly {

    private let servicesAssembler: ServicesAssembly

    init(servicesAssembler: ServicesAssembly) {
        self.servicesAssembler = servicesAssembler
    }

    public func build() -> UIViewController {
        let presenter = PaymentPresenterImpl(
            currencyService: servicesAssembler.currencyService,
            paymentService: servicesAssembler.paymentService,
            orderService: servicesAssembler.orderService
        )
        let viewController = PaymentViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}
