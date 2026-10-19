//
//  CartViewController.swift
//  FakeNFT
//
//  Created by Ekaterina on 11.10.2026.
//

import UIKit
import ProgressHUD

protocol CartViewControllerProtocol: AnyObject, ErrorView, LoadingView {
    func display()
    func showEmptyState()
}

final class CartViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let sideInset: CGFloat = 16
        static let bottomPanelHeight: CGFloat = 76
        static let labelsToButtonSpacing: CGFloat = 24
        static let payButtonHeight: CGFloat = 44
        static let payButtonMaxWidth: CGFloat = 240
        static let loadingBackgroundSize: CGFloat = 60
        static let rowHeight: CGFloat = 140
        static let cornerRadius: CGFloat = 12
        static let payButtonCornerRadius: CGFloat = 16
        static let labelsStackSpacing: CGFloat = 2
    }

    // MARK: - Properties

    internal lazy var activityIndicator = UIActivityIndicatorView()

    // MARK: - Private Properties

    private let presenter: CartPresenterProtocol?

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = Constants.rowHeight
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
        view.layer.cornerRadius = Constants.cornerRadius
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
        label.textColor = .ypGreenUniversal
        return label
    }()

    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Cart.pay", comment: ""), for: .normal)
        button.titleLabel?.font = .bodyBold
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .segmentActive
        button.layer.cornerRadius = Constants.payButtonCornerRadius
        button.addAction(UIAction { [weak self] _ in
            self?.presenter?.didTapPay()
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var labelsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [countLabel, priceLabel])
        stackView.axis = .vertical
        stackView.spacing = Constants.labelsStackSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var emptyCartTextLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Cart.empty", comment: "Empty cart placeholder")
        label.font = .caption3Bold
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    private lazy var loadingBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGrey
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private lazy var sortButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.tintColor = .ypBlack
        let action = UIAction(image: UIImage(resource: .sortIcon)) { [weak self] _ in
            self?.confirmSortOptions { option in self?.presenter?.didSelectSort(option: option) }
        }
        button.primaryAction = action
        return button
    }()

    private var isFirstLoad = true

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
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }

    // MARK: - Private Methods

    private func setupLayout() {

        navigationItem.rightBarButtonItem = sortButton

        bottomPanel.addSubview(labelsStack)
        bottomPanel.addSubview(payButton)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        loadingBackgroundView.addSubview(activityIndicator)

        view.addSubview(tableView)
        view.addSubview(bottomPanel)
        view.addSubview(emptyCartTextLabel)
        view.addSubview(loadingBackgroundView)
        view.addSubview(activityIndicator)

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
            preferredWidth,

            emptyCartTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCartTextLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            loadingBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingBackgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingBackgroundView.widthAnchor.constraint(equalToConstant: Constants.loadingBackgroundSize),
            loadingBackgroundView.heightAnchor.constraint(equalToConstant: Constants.loadingBackgroundSize),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func updateSummary() {
        let count = self.presenter?.nftCartViewModelArray.count ?? 0
        let price = self.presenter?.total ?? 0
        let currency = String(format: NSLocalizedString("Cart.currency.ETH", comment: ""))
        countLabel.text = String(format: NSLocalizedString("Cart.count", comment: ""), count)
        priceLabel.text = String(format: "%.2f \(currency)", price)
    }

}

// MARK: - CartViewControllerProtocol

extension CartViewController: CartViewControllerProtocol {
    func display() {
        tableView.reloadData()
        updateSummary()
        bottomPanel.isHidden = false
        emptyCartTextLabel.isHidden = true
        tableView.isHidden = false
    }

    func showEmptyState() {
        bottomPanel.isHidden = true
        emptyCartTextLabel.isHidden = false
        tableView.isHidden = true
    }

    func showLoading() {
        let hasLoadedItems = (presenter?.nftCartViewModelArray.count ?? 0) > 0
        loadingBackgroundView.isHidden = isFirstLoad || !hasLoadedItems
        bottomPanel.isHidden = isFirstLoad || !hasLoadedItems
        sortButton.isHidden = isFirstLoad || !hasLoadedItems
        activityIndicator.startAnimating()
        isFirstLoad = false
        emptyCartTextLabel.isHidden = true
        tableView.isUserInteractionEnabled = false
        payButton.isEnabled = false
        tableView.isHidden = false
        sortButton.isEnabled = false
    }

    func hideLoading() {
        activityIndicator.stopAnimating()
        tableView.isUserInteractionEnabled = true
        payButton.isEnabled = true
        loadingBackgroundView.isHidden = true
        sortButton.isHidden = false
        sortButton.isEnabled = true
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
        return presenter?.nftCartViewModelArray.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: CartViewCell.reuseIdentifier, for: indexPath) as? CartViewCell,
            let model = presenter?.nftCartViewModelArray[indexPath.row]
        else { return UITableViewCell() }
        cell.configure(nft: model)
        return cell
    }
}

// MARK: - Sort

extension CartViewController {
    func confirmSortOptions(onConfirm: @escaping (_ option: CartSortOption) -> Void) {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Common.sort", comment: ""), preferredStyle: .actionSheet)

        CartSortOption.allCases.forEach { option in
            alert.addAction(UIAlertAction(title: option.title, style: .default) { _ in onConfirm(option) })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Common.close", comment: ""), style: .cancel))
        present(alert, animated: true)
    }
}
