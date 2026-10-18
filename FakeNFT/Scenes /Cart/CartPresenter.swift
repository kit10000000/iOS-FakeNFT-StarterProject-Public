//
//  CartPresenter.swift
//  FakeNFT
//
//  Created by Ekaterina on 12.10.2026.
//

import Foundation

// MARK: - Protocol

protocol CartPresenterProtocol {
    var nftCartViewModelArray: [NftCartViewModel] { get }
    var total: Double? { get }
    func viewWillAppear()
    func didTapPay()
}

// MARK: - State

enum CartState {
    case initial, loading, empty, failed(Error), data(Order)
}

final class CartPresenterImpl: CartPresenterProtocol {

    // MARK: - Properties

    weak var view: CartViewControllerProtocol?
    private(set) var nftCartViewModelArray: [NftCartViewModel] = []

    var total: Double? {
        return nfts.map { $0.price }.reduce(0, +)
    }

    // MARK: - Private Properties

    private var order: Order?
    private var nfts: [Nft] = [] {
        didSet {
            nftCartViewModelArray = nfts.map {
                NftCartViewModel(
                    name: $0.name,
                    image: $0.images.first,
                    rating: $0.rating,
                    price: $0.price
                )
            }
        }
    }

    private let orderService: OrderService
    private let nftService: NftService
    private let storage: CartStorageProtocol

    private var state = CartState.initial {
        didSet {
            stateDidChanged()
        }
    }

    // MARK: - Initializers

    init(orderService: OrderService, nftService: NftService, storage: CartStorageProtocol) {
        self.orderService = orderService
        self.nftService = nftService
        self.storage = storage
    }

    // MARK: - Methods

    func viewWillAppear() {
        state = .loading
    }

    func didTapPay() {
        print("lets pay")
    }

    // MARK: - Private Methods

    private func stateDidChanged() {
        switch state {
        case .initial:
            assertionFailure("can't move to initial state")
        case .loading:
            view?.showLoading()
            loadOrder()
        case .data:
            view?.hideLoading()
            view?.display()
        case .failed(let error):
            let errorModel = makeErrorModel(error)
            view?.hideLoading()
            view?.showError(errorModel)
        case .empty:
            view?.hideLoading()
            view?.showEmptyState()
        }
    }

    private func loadOrder() {
        orderService.getOrder(id: "1") { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let order):
                self.order = order

                if order.nfts.isEmpty {
                    state = .empty
                } else {
                    self.loadNfts(ids: order.nfts)
                }
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

    private func loadNfts(ids: [String]) {
        let group = DispatchGroup()
        var loaded: [String: Nft] = [:]

        for id in ids {
            group.enter()
            nftService.loadNft(id: id) { result in
                if case .success(let nft) = result {
                    loaded[id] = nft
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self, let order = self.order else { return }
            self.nfts = ids.compactMap { loaded[$0] }
            self.state = .data(order)
        }
    }
}
