//
//  PaymentResultViewController.swift
//  FakeNFT
//
//  Created by Ekaterina on 26.10.2026.
//

import UIKit

final class PaymentResultViewController: UIViewController {

    // MARK: - Properties

    var onReturn: (() -> Void)?

    // MARK: - Private Properties

    private lazy var successImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .success)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var successLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Payment.result.success", comment: "Success payment message")
        label.font = .headline3
        label.textColor = .ypBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var cartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Payment.result.back", comment: ""), for: .normal)
        button.titleLabel?.font = .bodyBold
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .ypBlackUniversal
        button.layer.cornerRadius = Constants.cartButtonCornerRadius
        button.addAction(UIAction { [weak self] _ in
            self?.onReturn?()
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupUI()
    }

    // MARK: - Private Methods

    private func setupUI() {
        view.backgroundColor = .ypWhiteUniversal
        view.addSubview(successImageView)
        view.addSubview(successLabel)
        view.addSubview(cartButton)

        NSLayoutConstraint.activate([
            successImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            successImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),
            successImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.imageTopOffset),

            successLabel.topAnchor.constraint(equalTo: successImageView.bottomAnchor, constant: Constants.labelTopSpacing),
            successLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideInset),
            successLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideInset),

            cartButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.sideInset),
            cartButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.sideInset),
            cartButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomInset),
            cartButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
}

// MARK: - Constants

private extension PaymentResultViewController {
    enum Constants {
        static let imageSize: CGFloat = 278
        static let bottomInset: CGFloat = 16
        static let sideInset: CGFloat = 16
        static let cartButtonCornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 60
        static let labelTopSpacing: CGFloat = 20
        static let imageTopOffset: CGFloat = 150
    }
}
