//
//  CartViewController.swift
//  FakeNFT
//
//  Created by Ekaterina on 11.10.2026.
//

import UIKit

protocol CartViewControllerProtocol: AnyObject, ErrorView, LoadingView {
    func display()
}

final class CartViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let sideInset: CGFloat = 16
        static let bottomPanelHeight: CGFloat = 76
        static let labelsToButtonSpacing: CGFloat = 24
        static let payButtonHeight: CGFloat = 44
        static let payButtonMaxWidth: CGFloat = 240
    }

    // MARK: - Properties

    internal lazy var activityIndicator = UIActivityIndicatorView()

    // MARK: - Private Properties

    private let presenter: CartPresenterProtocol?

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.isScrollEnabled = true
        tableView.rowHeight = 140
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CartViewCell.self, forCellReuseIdentifier: CartViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private lazy var bottomPanel: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .segmentInactive
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .caption1
        label.textColor = .textPrimary
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = UIColor(hexString: "1C9F00")
        return label
    }()

    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Cart.pay", comment: ""), for: .normal)
        button.titleLabel?.font = .bodyBold
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .segmentActive
        button.layer.cornerRadius = 16
        button.addAction(UIAction { [weak self] _ in
            self?.presenter?.didTapPay()
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var labelsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [countLabel, priceLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Initializers

    init(presenter: CartPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        bottomPanel.addSubview(labelsStack)
        bottomPanel.addSubview(payButton)

        view.addSubview(tableView)
        view.addSubview(bottomPanel)

        let preferredWidth = payButton.widthAnchor.constraint(equalToConstant: Constants.payButtonMaxWidth)
        preferredWidth.priority = .defaultHigh

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomPanel.topAnchor),

            bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomPanel.heightAnchor.constraint(equalToConstant: Constants.bottomPanelHeight),

            labelsStack.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: Constants.sideInset),
            labelsStack.centerYAnchor.constraint(equalTo: bottomPanel.centerYAnchor),

            payButton.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -Constants.sideInset),
            payButton.centerYAnchor.constraint(equalTo: bottomPanel.centerYAnchor),
            payButton.leadingAnchor.constraint(greaterThanOrEqualTo: labelsStack.trailingAnchor, constant: Constants.labelsToButtonSpacing),
            payButton.heightAnchor.constraint(equalToConstant: Constants.payButtonHeight),
            payButton.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.payButtonMaxWidth),
            preferredWidth
        ])

        presenter?.viewDidLoad()
    }

    // MARK: - Private Methods

    private func updateSummary() {
        let count = self.presenter?.nfts.count ?? 0
        let price = self.presenter?.total ?? 0
        countLabel.text = "\(count) NFT"
        priceLabel.text = "\(price) ETH"
    }
}

// MARK: - CartViewControllerProtocol

extension CartViewController: CartViewControllerProtocol {
    func display() {
        tableView.reloadData()
        updateSummary()
    }
}

// MARK: - UITableViewDelegate

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.nfts.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartViewCell.reuseIdentifier, for: indexPath)
        guard let cartViewCell = cell as? CartViewCell else {
            return UITableViewCell()
        }
        return cartViewCell
    }
}
