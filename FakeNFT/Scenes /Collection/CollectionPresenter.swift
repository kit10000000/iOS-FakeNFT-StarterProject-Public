//
//  CollectionPresenter.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 13.10.2026.
//

import Foundation

protocol CollectionView: AnyObject {
    func showLoading()
    func hideLoading()
    func showError(_ model: ErrorModel)
    func setGridInteractionEnabled(_ isEnabled: Bool)
    func showCollection(_ header: CollectionHeaderModel)
    func showNfts(_ nfts: [Nft], likedIds: Set<String>, cartIds: Set<String>)
    func openAuthorWebsite(_ url: URL)
    func openNft(with id: String)
}

final class CollectionPresenter {

    weak var view: CollectionView?

    private enum State {
        case loading
        case data
        case failed
    }

    private let collection: NftCollection
    private let nftService: NftService
    private let likesService: LikesService
    private let orderService: CatalogOrderService
    private let stateQueue = DispatchQueue(label: "catalog.collection.load", qos: .userInitiated)
    private var nfts: [Nft] = []
    private var likedIds: [String] = []
    private var cartIds: [String] = []
    private var state: State = .loading
    private var isOpening = false

    init(collection: NftCollection, nftService: NftService, likesService: LikesService, orderService: CatalogOrderService) {
        self.collection = collection
        self.nftService = nftService
        self.likesService = likesService
        self.orderService = orderService
    }

    func viewDidLoad() {
        view?.showCollection(makeHeaderModel())
        load()
    }

    func load() {
        let ids = collection.nfts
        guard !ids.isEmpty else {
            state = .data
            nfts = []
            likedIds = []
            cartIds = []
            view?.hideLoading()
            view?.setGridInteractionEnabled(true)
            view?.showNfts([], likedIds: [], cartIds: [])
            return
        }

        state = .loading
        view?.setGridInteractionEnabled(false)
        view?.showLoading()

        let group = DispatchGroup()
        var loaded = Array<Nft?>(repeating: nil, count: ids.count)
        var liked: [String] = []
        var cart: [String] = []
        var failed = false

        for (index, id) in ids.enumerated() {
            group.enter()
            nftService.loadNft(id: id) { [weak self] result in
                guard let self else {
                    group.leave()
                    return
                }
                self.stateQueue.async {
                    switch result {
                    case .success(let nft):
                        loaded[index] = nft
                    case .failure:
                        failed = true
                    }
                    group.leave()
                }
            }
        }

        group.enter()
        likesService.loadProfile { [weak self] result in
            guard let self else {
                group.leave()
                return
            }
            self.stateQueue.async {
                switch result {
                case .success(let profile):
                    liked = profile.likes
                case .failure:
                    failed = true
                }
                group.leave()
            }
        }

        group.enter()
        orderService.loadNftIds { [weak self] result in
            guard let self else {
                group.leave()
                return
            }
            self.stateQueue.async {
                switch result {
                case .success(let ids):
                    cart = ids
                case .failure:
                    failed = true
                }
                group.leave()
            }
        }

        group.notify(queue: stateQueue) { [weak self] in
            guard let self else { return }
            let received = loaded.compactMap { $0 }
            let success = !failed && received.count == ids.count
            DispatchQueue.main.async {
                self.view?.hideLoading()
                if success {
                    self.state = .data
                    self.nfts = received
                    self.likedIds = liked
                    self.cartIds = cart
                    self.view?.showNfts(received, likedIds: Set(liked), cartIds: Set(cart))
                    self.view?.setGridInteractionEnabled(true)
                } else {
                    self.state = .failed
                    self.view?.setGridInteractionEnabled(false)
                    self.view?.showError(self.makeErrorModel { [weak self] in
                        self?.load()
                    })
                }
            }
        }
    }

    func viewWillAppear() {
        isOpening = false
    }

    func didTapAuthor() {
        guard !isOpening else { return }
        guard let url = URL(string: makeHeaderModel().authorURL) else { return }
        guard let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else { return }
        isOpening = true
        view?.openAuthorWebsite(url)
    }

    func didSelectNft(at index: Int) {
        guard state == .data, !isOpening, nfts.indices.contains(index) else { return }
        isOpening = true
        view?.openNft(with: nfts[index].id)
    }

    func didTapLike(id: String) {
    }

    func didTapCart(id: String) {
    }

    private func makeHeaderModel() -> CollectionHeaderModel {
        CollectionHeaderModel(
            cover: collection.cover,
            name: collection.name,
            authorName: collection.author,
            authorURL: collection.author,
            description: collection.description
        )
    }

    private func makeErrorModel(retry: @escaping () -> Void) -> ErrorModel {
        let message = NSLocalizedString("Error.network", comment: "")
        let actionText = NSLocalizedString("Error.repeat", comment: "")
        return ErrorModel(message: message, actionText: actionText, action: retry)
    }
}
