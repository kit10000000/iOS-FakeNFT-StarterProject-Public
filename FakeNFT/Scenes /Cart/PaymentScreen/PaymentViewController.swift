//
//  PaymentViewController.swift
//  FakeNFT
//
//  Created by Ekaterina on 24.10.2026.
//

import UIKit

protocol PaymentViewControllerProtocol: AnyObject, ErrorView, LoadingView {
    func display()
    func showLoading()
    func hideLoading()
}

final class PaymentViewController: UIViewController {

    // MARK: - Properties

    internal lazy var activityIndicator = UIActivityIndicatorView()

    // MARK: - Private Properties

    private let presenter: PaymentPresenterProtocol?

    // MARK: - Initializers

    init(presenter: PaymentPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        setupLayout()
    }

    // MARK: - Private Methods

    private func setupLayout() {
    }
}

// MARK: - PaymentViewControllerProtocol

extension PaymentViewController: PaymentViewControllerProtocol {
    func display() {
    }

    func showLoading() {
        activityIndicator.startAnimating()
    }

    func hideLoading() {
        activityIndicator.stopAnimating()
    }
}
