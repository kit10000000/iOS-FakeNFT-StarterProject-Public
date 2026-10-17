//
//  RatingView.swift
//  FakeNFT
//
//  Created by Ekaterina on 13.10.2026.
//

import UIKit

final class RatingView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let starsCount = 5
        static let starSize: CGFloat = 12
        static let spacing: CGFloat = 2
    }

    // MARK: - Private Properties

    private lazy var stars: [UIImageView] = (0..<Constants.starsCount).map { _ in
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .ratingStar)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .ypLightGrey
        return imageView
    }

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: stars)
        stack.axis = .horizontal
        stack.spacing = Constants.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Methods

    func configure(rating: Int) {
        let value = min(max(rating, 0), Constants.starsCount)
        for (index, star) in stars.enumerated() {
            star.tintColor = index < value ? .ypYellowUniversal : .ypLightGrey
        }
    }

    // MARK: - Private Methods

    private func setupLayout() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        stars.forEach {
            $0.widthAnchor.constraint(equalToConstant: Constants.starSize).isActive = true
            $0.heightAnchor.constraint(equalToConstant: Constants.starSize).isActive = true
        }
    }
}
