//
//  CartViewCell.swift
//  FakeNFT
//
//  Created by Ekaterina on 12.10.2026.
//

import UIKit

final class CartViewCell: UITableViewCell {

    // MARK: - Constants

    static let reuseIdentifier = "CartViewCell"

    private enum Constants {
        static let sideInset: CGFloat = 16
        static let imageSize: CGFloat = 108
        static let deleteButtonSize: CGFloat = 40
        static let imageToLabelsSpacing: CGFloat = 20
        static let labelsToButtonSpacing: CGFloat = 8
    }

    // MARK: - Private Properties

    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .ypLightGrey
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var priceCaptionLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Cart.price", comment: "")
        label.textColor = .textPrimary
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypBlack
        return label
    }()

    private lazy var ratingView: RatingView = RatingView()

    private lazy var labelsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, ratingView, priceCaptionLabel, priceLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.setCustomSpacing(12, after: ratingView)
        return stackView
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .cartDelete), for: .normal)
        button.tintColor = .segmentActive
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            #if DEBUG
            print("delete from cart")
            #endif
        }, for: .touchUpInside)
        return button
    }()

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(nftImageView)
        contentView.addSubview(labelsStack)
        contentView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.sideInset),
            nftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            nftImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),

            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.sideInset),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: Constants.deleteButtonSize),
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.deleteButtonSize),

            labelsStack.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: Constants.imageToLabelsSpacing),
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: deleteButton.leadingAnchor, constant: -Constants.labelsToButtonSpacing),
            labelsStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Methods

    func configure(nft: NftCartViewModel) {
        titleLabel.text = nft.name
        nftImageView.kf.setImage(with: nft.image)
        let currency = String(format: NSLocalizedString("Cart.currency.ETH", comment: ""))
        priceLabel.text = String(format: "%.2f \(currency)", nft.price)
        ratingView.configure(rating: nft.rating)
    }
}
