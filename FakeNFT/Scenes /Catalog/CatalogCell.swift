//
//  CatalogCell.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 12.10.2026.
//

import UIKit
import Kingfisher

final class CatalogCell: UITableViewCell, ReuseIdentifying {
    
    private let coverContainer = UIView()
    private let coverImageView = UIImageView()
    private let nameLabel = UILabel()
    private let countLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        countLabel.text = nil
    }
    
    func configure(with collection: NftCollection) {
        coverImageView.kf.setImage(with: collection.cover)
        nameLabel.text = collection.name
        countLabel.text = "(\(collection.nfts.count))"
    }
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .ypWhiteUniversal

        coverContainer.clipsToBounds = true
        coverContainer.layer.cornerRadius = 8
        coverContainer.backgroundColor = .ypLightGrey

        coverImageView.contentMode = .scaleAspectFill
        coverContainer.addSubview(coverImageView)
        coverImageView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .bodyBold
        countLabel.font = .bodyBold
        nameLabel.textColor = .ypBlackUniversal
        countLabel.textColor = .ypBlackUniversal

        let spacer = UIView()
        let titleRow = UIStackView(arrangedSubviews: [nameLabel, countLabel, spacer])
        titleRow.axis = .horizontal
        titleRow.spacing = 4
        titleRow.alignment = .firstBaseline
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let contentStack = UIStackView(arrangedSubviews: [coverContainer, titleRow])
        contentStack.axis = .vertical
        contentStack.spacing = 8

        contentView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            coverContainer.heightAnchor.constraint(equalToConstant: 140),
            coverImageView.topAnchor.constraint(equalTo: coverContainer.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: coverContainer.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: coverContainer.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalTo: coverImageView.widthAnchor, multiplier: 1240.0 / 1500.0),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])

        countLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
}
