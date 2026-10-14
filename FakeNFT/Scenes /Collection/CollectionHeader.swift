//
//  CollectionHeader.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 13.10.2026.
//

import UIKit
import Kingfisher

final class CollectionHeader: UICollectionReusableView {

    static let reuseIdentifier = "CollectionHeader"

    private let coverContainer = UIView()
    private let coverImageView = UIImageView()
    private let nameLabel = UILabel()
    private let authorCaptionLabel = UILabel()
    private let authorButton = UIButton(type: .system)
    var onAuthorTap: (() -> Void)?
    private let descriptionLabel = UILabel()

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
        authorButton.setTitle(nil, for: .normal)
        descriptionLabel.text = nil
        onAuthorTap = nil
    }

    func configure(with collection: NftCollection) {
        coverImageView.kf.setImage(with: collection.cover)
        nameLabel.text = collection.name
        authorButton.setTitle(authorLinkTitle(collection.author), for: .normal)
        descriptionLabel.text = collection.description
    }

    private func authorLinkTitle(_ author: String) -> String {
        if author == "https://ya.ru" {
            return "John Doe"
        }
        return author
    }

    @objc private func authorButtonTapped() {
        onAuthorTap?()
    }

    private func setupView() {
        backgroundColor = .ypWhiteUniversal

        coverContainer.clipsToBounds = true
        coverContainer.layer.cornerRadius = 12
        coverContainer.backgroundColor = .ypLightGrey

        coverImageView.contentMode = .scaleAspectFill
        coverContainer.addSubview(coverImageView)
        coverImageView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .headline3
        nameLabel.textColor = .ypBlackUniversal
        nameLabel.numberOfLines = 0

        authorCaptionLabel.text = "Автор коллекции:"
        authorCaptionLabel.font = .bodyRegular
        authorCaptionLabel.textColor = .ypBlackUniversal

        authorButton.titleLabel?.font = .bodyRegular
        authorButton.setTitleColor(.ypBlueUniversal, for: .normal)
        authorButton.addTarget(self, action: #selector(authorButtonTapped), for: .touchUpInside)
        authorButton.contentHorizontalAlignment = .leading

        descriptionLabel.font = .bodyRegular
        descriptionLabel.textColor = .ypBlackUniversal
        descriptionLabel.numberOfLines = 0

        let authorRow = UIStackView(arrangedSubviews: [authorCaptionLabel, authorButton])
        authorRow.axis = .horizontal
        authorRow.spacing = 4
        authorRow.alignment = .firstBaseline
        authorCaptionLabel.setContentHuggingPriority(.required, for: .horizontal)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, authorRow, descriptionLabel])
        textStack.axis = .vertical
        textStack.spacing = 16
        textStack.isLayoutMarginsRelativeArrangement = true
        textStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let contentStack = UIStackView(arrangedSubviews: [coverContainer, textStack])
        contentStack.axis = .vertical
        contentStack.spacing = 16

        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            coverContainer.heightAnchor.constraint(equalToConstant: 279),
            coverImageView.topAnchor.constraint(equalTo: coverContainer.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: coverContainer.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: coverContainer.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalTo: coverImageView.widthAnchor, multiplier: 1240.0 / 1500.0),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }
}
