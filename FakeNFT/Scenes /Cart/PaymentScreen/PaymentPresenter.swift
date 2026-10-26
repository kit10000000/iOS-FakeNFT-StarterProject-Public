//
//  PaymentPresenter.swift
//  FakeNFT
//
//  Created by Ekaterina on 24.10.2026.
//

import Foundation

protocol PaymentPresenterProtocol {
    func viewDidLoad()
    var currencyViewModelArray: [CurrencyViewModel] { get }
    func didSelectCurrency(at index: Int)
}

// MARK: - State

enum PaymentScreenState {
    case initial, loading, failed(Error), data
}

final class PaymentPresenterImpl: PaymentPresenterProtocol {

    // MARK: - Properties

    weak var view: PaymentViewControllerProtocol?

    // MARK: - Private Properties

    private(set) var currencyViewModelArray: [CurrencyViewModel] = []
    private var selectedCurrency: Currency? = nil

    private var currencyList: [Currency] = [] {
        didSet {
            currencyViewModelArray = currencyList.map {
                return CurrencyViewModel(
                    title: $0.title,
                    name: $0.name,
                    imageURL: $0.image.flatMap { URL(string: $0) }
                )
            }
        }
    }

    private var state = PaymentScreenState.initial {
        didSet {
            stateDidChanged()
        }
    }

    private let currencyService: CurrencyService
    private let paymentService: PaymentService

    // MARK: - Initializers

    init(currencyService: CurrencyService, paymentService: PaymentService) {
        self.currencyService = currencyService
        self.paymentService = paymentService
    }

    // MARK: - Methods

    func viewDidLoad() {
        state = .loading
    }

    func didSelectCurrency(at index: Int) {
        self.selectedCurrency = currencyList[index]
        view?.setPayButtonEnabled(true)
    }

    // MARK: - Private Methods

    private func stateDidChanged() {
        switch state {
        case .initial:
            assertionFailure("can't move to initial state")
        case .loading:
            view?.showLoading()
            loadCurrencies()
        case .data:
            view?.hideLoading()
            view?.display()
        case .failed(let error):
            let errorModel = makeErrorModel(error)
            view?.hideLoading()
            view?.showError(errorModel)
        }
    }

    private func loadCurrencies() {
        currencyService.getCurrencies { [weak self] result in
            guard let self else {
                return
            }
            switch result {
            case .success(let currencies):
                self.currencyList = currencies
                state = .data
            case .failure(let error):
                self.state = .failed(error)
            }
        }
    }

    private func makeErrorModel(_ error: Error) -> ErrorModel {
        let message: String
        switch error {
        case is NetworkClientError:
            message = NSLocalizedString("Error.network", comment: "")
        default:
            message = NSLocalizedString("Error.unknown", comment: "")
        }

        return ErrorModel(
            message: message,
            actionText: NSLocalizedString("Error.repeat", comment: ""),
            action: { [weak self] in self?.state = .loading },
            cancelText: NSLocalizedString("Error.cancel", comment: ""),
            cancelAction: nil
        )
    }
}
