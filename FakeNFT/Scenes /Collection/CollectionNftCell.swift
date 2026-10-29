//
//  CollectionNftCell.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 13.10.2026.
//

import UIKit
import Kingfisher

final class CollectionNftCell: UICollectionViewCell, ReuseIdentifying {

    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private let coverImageView = UIImageView()
    private let likeButton = UIButton(type: .system)
    private let ratingView = RatingView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let cartButton = UIButton(type: .system)
    var onLikeTap: (() -> Void)?
    var onCartTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.kf.cancelDownloadTask()
        coverImageView.image = nil
        nameLabel.text = nil
        priceLabel.text = nil
        ratingView.configure(rating: 0)
        setLiked(false)
        setInCart(false)
        onLikeTap = nil
        onCartTap = nil
    }

    func configure(with nft: Nft, isLiked: Bool, isInCart: Bool) {
        coverImageView.kf.setImage(with: nft.images.first)
        ratingView.configure(rating: nft.rating)
        nameLabel.text = nft.name
        if let priceText = Self.priceFormatter.string(from: NSNumber(value: nft.price)) {
            priceLabel.text = priceText + " ETH"
        }
        setLiked(isLiked)
        setInCart(isInCart)
    }

    private func setupView() {
        backgroundColor = .ypWhiteUniversal
        contentView.backgroundColor = .ypWhiteUniversal

        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 12
        coverImageView.backgroundColor = .ypLightGrey

        let imageContainer = UIView()
        imageContainer.clipsToBounds = true
        imageContainer.layer.cornerRadius = 12
        imageContainer.addSubview(coverImageView)
        coverImageView.constraintEdges(to: imageContainer)
        imageContainer.addSubview(likeButton)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        setLiked(false)
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)

        nameLabel.font = .bodyBold
        nameLabel.textColor = .ypBlackUniversal
        nameLabel.numberOfLines = 1

        priceLabel.font = .caption2
        priceLabel.textColor = .ypBlackUniversal
        priceLabel.numberOfLines = 1

        setInCart(false)
        cartButton.tintColor = .ypBlackUniversal
        cartButton.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        cartButton.setContentHuggingPriority(.required, for: .horizontal)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, priceLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let infoRow = UIStackView(arrangedSubviews: [textStack, cartButton])
        infoRow.axis = .horizontal
        infoRow.alignment = .center

        let contentStack = UIStackView(arrangedSubviews: [imageContainer, ratingView, infoRow])
        contentStack.axis = .vertical
        contentStack.spacing = 8

        contentView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageContainer.heightAnchor.constraint(equalTo: imageContainer.widthAnchor),
            likeButton.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 42),
            likeButton.heightAnchor.constraint(equalToConstant: 42),
            cartButton.widthAnchor.constraint(equalToConstant: 40),
            cartButton.heightAnchor.constraint(equalToConstant: 40),
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    private func setLiked(_ isLiked: Bool) {
        likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22)), for: .normal)
        likeButton.tintColor = isLiked ? .ypRedUniversal : .ypWhiteUniversal
    }

    private func setInCart(_ isInCart: Bool) {
        let imageName = isInCart ? "nftCartDelete" : "nftCartAdd"
        cartButton.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal), for: .normal)
    }

    @objc private func likeButtonTapped() {
        onLikeTap?()
    }

    @objc private func cartButtonTapped() {
        onCartTap?()
    }
}
