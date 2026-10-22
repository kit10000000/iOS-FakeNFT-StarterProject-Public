//
//  CartDeleteViewController.swift
//  FakeNFT
//
//  Created by Ekaterina on 19.10.2026.
//

import UIKit

protocol CartDeleteViewControllerDelegate: AnyObject {
    func didConfirmDelete(nftId: Int)
}

final class CartDeleteViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: CartDeleteViewControllerDelegate?

    // MARK: - Private Properties

    private var nftId: Int?

    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let effect = UIVisualEffectView(effect: blurEffect)
        effect.translatesAutoresizingMaskIntoConstraints = false
        return effect
    }()

    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .ypLightGrey
        return imageView
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Cart.delete", comment: ""), for: .normal)
        button.setTitleColor(.ypRedUniversal, for: .normal)
        button.backgroundColor = .segmentActive
        button.layer.cornerRadius = Constants.cornerRadius
        button.addAction(UIAction { [weak self] _ in
            guard let self, let nftId = self.nftId else {
                return
            }
            self.delegate?.didConfirmDelete(nftId: nftId)
            self.dismiss(animated: true)
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var returnButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Cart.return", comment: ""), for: .normal)
        button.setTitleColor(.ypWhiteUniversal, for: .normal)
        button.backgroundColor = .segmentActive
        button.layer.cornerRadius = Constants.cornerRadius
        button.addAction(UIAction { [weak self] _ in
            guard let self else {
                return
            }
            self.dismiss(animated: true)
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [deleteButton, returnButton])
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.spacing = Constants.buttonsSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var confirmationDeleteLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Cart.confirmation", comment: "")
        label.font = .caption2
        label.textColor = .ypBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nftImageView, confirmationDeleteLabel, buttonStackView])
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setCustomSpacing(Constants.imageToLabelSpacing, after: nftImageView)
        stack.setCustomSpacing(Constants.labelToButtonsSpacing, after: confirmationDeleteLabel)
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    // MARK: - Methods

    func configure(image: URL, nftId: Int) {
        self.nftId = nftId
        nftImageView.kf.setImage(with: image)
    }

    // MARK: - Private Methods

    private func setupLayout() {
        view.addSubview(blurView)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: Constants.stackViewCenterYOffset),
            stackView.widthAnchor.constraint(equalToConstant: Constants.stackViewWidth),

            confirmationDeleteLabel.widthAnchor.constraint(equalToConstant: Constants.confirmationLabelWidth),

            nftImageView.heightAnchor.constraint(equalToConstant: Constants.nftImageSize),
            nftImageView.widthAnchor.constraint(equalToConstant: Constants.nftImageSize),

            buttonStackView.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            buttonStackView.widthAnchor.constraint(equalToConstant: Constants.stackViewWidth)
        ])
    }
}

// MARK: - Constants

private extension CartDeleteViewController {
    enum Constants {
        static let nftImageSize: CGFloat = 108
        static let confirmationLabelWidth: CGFloat = 180
        static let buttonHeight: CGFloat = 44
        static let stackViewWidth: CGFloat = 262
        static let stackViewCenterYOffset: CGFloat = -40
        static let cornerRadius: CGFloat = 16
        static let buttonsSpacing: CGFloat = 2
        static let stackSpacing: CGFloat = 10
        static let imageToLabelSpacing: CGFloat = 12
        static let labelToButtonsSpacing: CGFloat = 20
    }
}
