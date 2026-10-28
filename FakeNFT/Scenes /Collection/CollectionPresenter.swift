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
    func updateNft(at index: Int, isLiked: Bool, isInCart: Bool)
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
    
    private struct ListChange {
        let id: String
        let include: Bool
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
    private var confirmedLikedIds: [String] = []
    private var confirmedCartIds: [String] = []
    private var likeChanges: [ListChange] = []
    private var cartChanges: [ListChange] = []
    private var likeInFlightId: String?
    private var cartInFlightId: String?

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
                    self.confirmedLikedIds = liked
                    self.confirmedCartIds = cart
                    self.view?.showCollection(self.makeHeaderModel())
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

    func didCloseNft() {
        isOpening = false
    }

    func didTapAuthor() {
        guard !isOpening else { return }
        guard let url = makeHeaderModel().authorURL else { return }
        isOpening = true
        view?.openAuthorWebsite(url)
    }

    func didSelectNft(at index: Int) {
        guard state == .data, !isOpening, nfts.indices.contains(index) else { return }
        isOpening = true
        view?.openNft(with: nfts[index].id)
    }

    func didTapLike(id: String) {
        guard state == .data, !likeChanges.contains(where: { $0.id == id }), let index = nfts.firstIndex(where: { $0.id == id }) else { return }
        let include = !likedIds.contains(id)
        let change = ListChange(id: id, include: include)
        likedIds = applying([change], to: likedIds)
        view?.updateNft(at: index, isLiked: include, isInCart: cartIds.contains(id))
        likeChanges.append(change)
        sendNextLike()
    }

    func didTapCart(id: String) {
        guard state == .data, !cartChanges.contains(where: { $0.id == id }), let index = nfts.firstIndex(where: { $0.id == id }) else { return }
        let include = !cartIds.contains(id)
        let change = ListChange(id: id, include: include)
        cartIds = applying([change], to: cartIds)
        view?.updateNft(at: index, isLiked: likedIds.contains(id), isInCart: include)
        cartChanges.append(change)
        sendNextCart()
    }

    private func sendNextLike() {
        guard likeInFlightId == nil, let change = likeChanges.first else { return }
        likeInFlightId = change.id
        let likesToSend = applying([change], to: confirmedLikedIds)
        likesService.saveLikes(likesToSend) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.likeInFlightId = nil
                self.likeChanges.removeAll { $0.id == change.id }
                switch result {
                case .success(let profile):
                    self.confirmedLikedIds = profile.likes
                    self.likedIds = self.applying(self.likeChanges, to: profile.likes)
                    self.updateNft(id: change.id)
                case .failure:
                    self.likedIds = self.applying(self.likeChanges, to: self.confirmedLikedIds)
                    self.updateNft(id: change.id)
                    self.view?.showError(self.makeErrorModel { [weak self] in
                        self?.didTapLike(id: change.id)
                    })
                }
                self.sendNextLike()
            }
        }
    }

    private func sendNextCart() {
        guard cartInFlightId == nil, let change = cartChanges.first else { return }
        cartInFlightId = change.id
        orderService.loadNftIds { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.finishCart(change, result: .failure(error))
                }
            case .success(let serverIds):
                let ids = self.applying([change], to: serverIds)
                self.orderService.saveNftIds(ids) { [weak self] saveResult in
                    DispatchQueue.main.async {
                        guard let self else { return }
                        self.finishCart(change, result: saveResult)
                    }
                }
            }
        }
    }

    private func finishCart(_ change: ListChange, result: Result<[String], Error>) {
        cartInFlightId = nil
        cartChanges.removeAll { $0.id == change.id }
        switch result {
        case .success(let saved):
            self.confirmedCartIds = saved
            self.cartIds = self.applying(self.cartChanges, to: saved)
            self.updateNft(id: change.id)
        case .failure:
            self.cartIds = self.applying(self.cartChanges, to: self.confirmedCartIds)
            self.updateNft(id: change.id)
            self.view?.showError(self.makeErrorModel { [weak self] in
                self?.didTapCart(id: change.id)
            })
        }
        sendNextCart()
    }

    private func updateNft(id: String) {
        guard let index = nfts.firstIndex(where: { $0.id == id }) else { return }
        view?.updateNft(at: index, isLiked: likedIds.contains(id), isInCart: cartIds.contains(id))
    }

    private func applying(_ changes: [ListChange], to ids: [String]) -> [String] {
        var list = ids
        for change in changes {
            if change.include {
                if !list.contains(change.id) {
                    list.append(change.id)
                }
            } else {
                list.removeAll { $0 == change.id }
            }
        }
        return list
    }

    private func makeHeaderModel() -> CollectionHeaderModel {
        CollectionHeaderModel(
            cover: collection.cover,
            name: collection.name,
            authorName: collection.author,
            authorURL: authorWebsite(),
            description: collection.description
        )
    }

    private func authorWebsite() -> URL? {
        for nft in nfts {
            guard let url = nft.website, let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else {
                continue
            }
            return url
        }
        return nil
    }

    private func makeErrorModel(retry: @escaping () -> Void) -> ErrorModel {
        let message = NSLocalizedString("Error.network", comment: "")
        let actionText = NSLocalizedString("Error.repeat", comment: "")
        return ErrorModel(message: message, actionText: actionText, action: retry)
    }
}
