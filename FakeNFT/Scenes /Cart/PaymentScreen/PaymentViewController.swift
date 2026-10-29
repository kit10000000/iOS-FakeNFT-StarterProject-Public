//
//  PaymentViewController.swift
//  FakeNFT
//
//  Created by Ekaterina on 24.10.2026.
//

import UIKit

protocol PaymentViewControllerProtocol: AnyObject, ErrorView, LoadingView {
    func display()
    func showLoading()
    func hideLoading()
    func setPayButtonEnabled(_ isEnabled: Bool)
    func showPaymentSuccess()
}

final class PaymentViewController: UIViewController {

    // MARK: - Properties

    internal lazy var activityIndicator = UIActivityIndicatorView()

    // MARK: - Private Properties

    private let presenter: PaymentPresenterProtocol?

    private lazy var bottomPanel: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .segmentInactive
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Payment.button", comment: ""), for: .normal)
        button.titleLabel?.font = .bodyBold
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .ypGrayUniversal
        button.layer.cornerRadius = Constants.payButtonCornerRadius
        button.addAction(UIAction { [weak self] _ in
            self?.presenter?.didTapPay()
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false

        return button
    }()

    private lazy var loadingBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGrey
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private lazy var panelStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [agreementTextLabel, agreementButton, payButton])
        stackView.axis = .vertical
        stackView.setCustomSpacing(Constants.labelsStackSpacing, after: agreementButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var agreementTextLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Payment.agreement", comment: "Agreement text")
        label.font = .caption2
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Payment.title", comment: "title screen")
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var agreementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Payment.agreement.link", comment: ""), for: .normal)
        button.setTitleColor(.ypBlueUniversal, for: .normal)
        button.titleLabel?.font = .caption2
        button.contentHorizontalAlignment = .leading
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            guard let url = URL(string: Constants.agreementURLString) else {
                return
            }
            self?.navigationItem.backButtonDisplayMode = .minimal
            self?.navigationController?.pushViewController(
                WebViewController(url: url), animated: true
            )
        }, for: .touchUpInside)
        return button
    }()

    // MARK: - Initializers

    init(presenter: PaymentPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        setupLayout()
        collectionView.delegate = self
    }

    // MARK: - Private Methods

    private func setupLayout() {

        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = false
        collectionView.allowsSelection = true
        collectionView.dataSource = self
        collectionView.register(CurrencyViewCell.self, forCellWithReuseIdentifier: CurrencyViewCell.reuseIdentifier)
        view.addSubview(collectionView)

        navigationItem.titleView = titleLabel
        bottomPanel.addSubview(panelStack)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        loadingBackgroundView.addSubview(activityIndicator)

        view.addSubview(bottomPanel)
        view.addSubview(loadingBackgroundView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomPanel.topAnchor),

            bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomPanel.heightAnchor.constraint(equalToConstant: Constants.bottomPanelHeight),
            panelStack.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: Constants.sideInset),
            panelStack.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -Constants.sideInset),
            panelStack.topAnchor.constraint(equalTo: bottomPanel.topAnchor, constant: Constants.panelTopInset),
            payButton.heightAnchor.constraint(equalToConstant: Constants.payButtonHeight),

            loadingBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingBackgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingBackgroundView.widthAnchor.constraint(equalToConstant: Constants.loadingBackgroundSize),
            loadingBackgroundView.heightAnchor.constraint(equalToConstant: Constants.loadingBackgroundSize),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - PaymentViewControllerProtocol

extension PaymentViewController: PaymentViewControllerProtocol {
    func display() {
        collectionView.reloadData()
    }

    func showLoading() {
        activityIndicator.startAnimating()
    }

    func hideLoading() {
        activityIndicator.stopAnimating()
    }

    func setPayButtonEnabled(_ isEnabled: Bool) {
        payButton.isEnabled = isEnabled
        payButton.backgroundColor = .segmentActive
    }

    func showPaymentSuccess() {
        let resultVC = PaymentResultViewController()
        resultVC.onReturn = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        navigationController?.pushViewController(resultVC, animated: true)
    }
}

// MARK: - Constants

private extension PaymentViewController {
    enum Constants {
        static let sideInset: CGFloat = 16
        static let bottomPanelHeight: CGFloat = 186
        static let payButtonHeight: CGFloat = 60
        static let loadingBackgroundSize: CGFloat = 60
        static let cornerRadius: CGFloat = 12
        static let payButtonCornerRadius: CGFloat = 16
        static let labelsStackSpacing: CGFloat = 20
        static let panelTopInset: CGFloat = 16
        static let itemSpacing: CGFloat = 7
        static let itemHeight: CGFloat = 46
        static let columnsCount: CGFloat = 2
        static let agreementURLString = "https://yandex.ru/legal/practicum_termsofuse/"
    }
}

// MARK: - UICollectionViewDataSource

extension PaymentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.currencyViewModelArray.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrencyViewCell.reuseIdentifier, for: indexPath)
        guard let currencyCell = cell as? CurrencyViewCell,
              let entity = presenter?.currencyViewModelArray else {
            return UICollectionViewCell()
        }
        currencyCell.configure(currency: entity[indexPath.row])
        return currencyCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PaymentViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ cv: UICollectionView, layout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = Constants.itemSpacing
        let columns = Constants.columnsCount
        let insets = Constants.sideInset * 2
        let available = cv.bounds.width - insets - spacing * (columns - 1)
        let width = available / columns
        return CGSize(width: width, height: Constants.itemHeight)
    }

    func collectionView(_ cv: UICollectionView, layout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: Constants.sideInset, left: Constants.sideInset,
                     bottom: 0, right: Constants.sideInset)
    }

    func collectionView(_ cv: UICollectionView, layout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.itemSpacing
    }

    func collectionView(_ cv: UICollectionView, layout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.itemSpacing
    }
}

// MARK: - UICollectionViewDelegate

extension PaymentViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.didSelectCurrency(at: indexPath.row)
    }
}
