//
//  CatalogCell.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 12.10.2026.
//

import UIKit

final class CatalogCell: UITableViewCell, ReuseIdentifying {
    
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
        coverImageView.image = nil
        nameLabel.text = nil
        countLabel.text = nil
    }
    
    func configure(with collection: NftCollection) {
        nameLabel.text = collection.name
        countLabel.text = "(\(collection.nfts.count))"
    }
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .background
        
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 12
        coverImageView.backgroundColor = .segmentInactive
        
        nameLabel.font = .bodyBold
        countLabel.font = .bodyBold
        nameLabel.textColor = .closeButton
        countLabel.textColor = .closeButton
        
        let titleRow = UIStackView(arrangedSubviews: [nameLabel, countLabel])
        titleRow.axis = .horizontal
        titleRow.spacing = 4
        titleRow.alignment = .firstBaseline
        
        let contentStack = UIStackView(arrangedSubviews: [coverImageView, titleRow])
        contentStack.axis = .vertical
        contentStack.spacing = 8
        
        contentView.addSubview(contentStack)
        
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            coverImageView.heightAnchor.constraint(equalToConstant: 140),

            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        countLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
}
