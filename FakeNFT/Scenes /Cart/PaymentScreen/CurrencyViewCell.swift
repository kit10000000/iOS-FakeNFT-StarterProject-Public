//
//  CurrencyViewCell.swift
//  FakeNFT
//
//  Created by Ekaterina on 25.10.2026.
//

import UIKit

final class CurrencyViewCell: UICollectionViewCell {

    // MARK: - Constants

    static let reuseIdentifier = "CurrencyViewCell"

    private enum Constants {
        static let backgroundCornerRadius: CGFloat = 16
        static let imageSize: CGFloat = 36
        static let sideInset: CGFloat = 16
        static let imageToLabelsSpacing: CGFloat = 8
        static let labelsStackSpacing: CGFloat = 2
        static let imageBackgroundCornerRadius: CGFloat = 8
        static let imageBackgroundInset: CGFloat = 8
        static let imageInnerSize: CGFloat = 32
    }

    // MARK: - Properties

    override var isSelected: Bool {
        didSet {
            currencyBackgroundView.layer.borderWidth = isSelected ? 1 : 0
            currencyBackgroundView.layer.borderColor = isSelected ? UIColor.ypBlackUniversal.cgColor : UIColor.clear.cgColor
        }
    }

    // MARK: - Private Properties

    private lazy var currencyBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGrey
        view.layer.cornerRadius = Constants.backgroundCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .textPrimary
        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .ypGreenUniversal
        return label
    }()

    private lazy var labelsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, nameLabel])
        stackView.axis = .vertical
        stackView.spacing = Constants.labelsStackSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var currencyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var currencyImageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBlackUniversal
        view.layer.cornerRadius = Constants.imageBackgroundCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Methods

    func configure(currency: CurrencyViewModel) {
        titleLabel.text = currency.title
        nameLabel.text = currency.name
        currencyImageView.kf.setImage(with: currency.imageURL)
    }

    // MARK: - Private Methods

    private func setupUI() {
        contentView.addSubview(currencyBackgroundView)
        currencyBackgroundView.addSubview(currencyImageBackgroundView)
        currencyImageBackgroundView.addSubview(currencyImageView)
        currencyBackgroundView.addSubview(labelsStack)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            currencyBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            currencyBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            currencyBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            currencyBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            currencyImageBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.imageBackgroundInset),
            currencyImageBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            currencyImageBackgroundView.widthAnchor.constraint(equalToConstant: Constants.imageSize),

            currencyImageBackgroundView.heightAnchor.constraint(equalToConstant: Constants.imageSize),

            currencyImageView.centerXAnchor.constraint(equalTo: currencyImageBackgroundView.centerXAnchor),
            currencyImageView.centerYAnchor.constraint(equalTo: currencyImageBackgroundView.centerYAnchor),
            currencyImageView.widthAnchor.constraint(equalToConstant: Constants.imageInnerSize),
            currencyImageView.heightAnchor.constraint(equalToConstant: Constants.imageInnerSize),

            labelsStack.leadingAnchor.constraint(equalTo: currencyImageView.trailingAnchor, constant: Constants.imageToLabelsSpacing),
            labelsStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: currencyBackgroundView.trailingAnchor, constant: -Constants.sideInset)

        ])
    }
}
