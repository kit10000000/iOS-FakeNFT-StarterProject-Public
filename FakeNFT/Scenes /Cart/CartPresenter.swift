//
//  CartPresenter.swift
//  FakeNFT
//
//  Created by Ekaterina on 12.10.2026.
//

import Foundation

// MARK: - Protocol

protocol CartPresenterProtocol {
    func viewDidLoad()
}

// MARK: - State

enum CartState {
    case initial, loading, failed(Error), data(Order)
}

final class CartPresenterImpl: CartPresenterProtocol {

    // MARK: - Properties

    weak var view: CartViewControllerProtocol?

    // MARK: - Private Properties

    private let service: OrderService
    private var state = CartState.initial {
        didSet {
            stateDidChanged()
        }
    }

    // MARK: - Init

    init(service: OrderService) {
        self.service = service
    }

    // MARK: - Functions

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
            loadOrder()
        case .data(let order):
            view?.hideLoading()
            #if DEBUG
            print(order)
            #endif
        case .failed(let error):
            let errorModel = makeErrorModel(error)
            view?.hideLoading()
            view?.showError(errorModel)
        }
    }

    private func loadOrder() {
        service.getOrder(id: "1") { [weak self] result in
            switch result {
            case .success(let order):
                self?.state = .data(order)
            case .failure(let error):
                self?.state = .failed(error)
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

        let actionText = NSLocalizedString("Error.repeat", comment: "")
        return ErrorModel(message: message, actionText: actionText) { [weak self] in
            self?.state = .loading
        }
    }
}
