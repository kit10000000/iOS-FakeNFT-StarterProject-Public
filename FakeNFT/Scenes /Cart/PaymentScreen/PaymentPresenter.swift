//
//  PaymentPresenter.swift
//  FakeNFT
//
//  Created by Ekaterina on 24.10.2026.
//

import Foundation

protocol PaymentPresenterProtocol {
    func viewDidLoad()
}

// MARK: - State

enum PaymentScreenState {
    case initial, loading, failed(Error), data([Currency])
}

final class PaymentPresenterImpl: PaymentPresenterProtocol {

    // MARK: - Properties

    weak var view: PaymentViewControllerProtocol?

    // MARK: - Private Properties

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

    // MARK: - Private Methods

    private func stateDidChanged() {
        switch state {
        case .initial:
            assertionFailure("can't move to initial state")
        case .loading:
            view?.showLoading()
        case .data:
            view?.hideLoading()
        case .failed(let error):
            let errorModel = makeErrorModel(error)
            view?.hideLoading()
            view?.showError(errorModel)
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
