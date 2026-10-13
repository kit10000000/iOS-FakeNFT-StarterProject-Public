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
        authorButton.setTitle(collection.author, for: .normal)
        descriptionLabel.text = collection.description
    }
    
    @objc private func authorButtonTapped() {
        onAuthorTap?()
    }

    private func setupView() {
        backgroundColor = .ypWhite

        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 12
        coverImageView.backgroundColor = .ypLightGrey

        nameLabel.font = .headline3
        nameLabel.textColor = .ypBlack
        nameLabel.numberOfLines = 0

        authorCaptionLabel.text = "Автор коллекции:"
        authorCaptionLabel.font = .bodyRegular
        authorCaptionLabel.textColor = .ypBlack

        authorButton.titleLabel?.font = .bodyRegular
        authorButton.setTitleColor(.ypBlueUniversal, for: .normal)
        authorButton.addTarget(self, action: #selector(authorButtonTapped), for: .touchUpInside)
        authorButton.contentHorizontalAlignment = .leading

        descriptionLabel.font = .bodyRegular
        descriptionLabel.textColor = .ypBlack
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

        let contentStack = UIStackView(arrangedSubviews: [coverImageView, textStack])
        contentStack.axis = .vertical
        contentStack.spacing = 16

        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            coverImageView.heightAnchor.constraint(equalToConstant: 279),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }
}
