//
//  CartViewController.swift
//  FakeNFT
//
//  Created by Ekaterina on 11.10.2026.
//

import UIKit

protocol CartViewControllerProtocol: AnyObject, ErrorView, LoadingView {
}

final class CartViewController: UIViewController {

    private let presenter: CartPresenterProtocol

    internal lazy var activityIndicator = UIActivityIndicatorView()

    init(presenter: CartPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
}

extension CartViewController: CartViewControllerProtocol {

}
