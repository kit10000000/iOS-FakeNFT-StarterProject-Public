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
    private var isSavingLike = false
    private var isSavingCart = false

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
        guard let url = makeHeaderModel().authorURL else { return }
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
        guard state == .data, !isSavingLike, let index = nfts.firstIndex(where: { $0.id == id }) else { return }
        isSavingLike = true
        let wasLiked = likedIds.contains(id)
        if let current = likedIds.firstIndex(of: id) {
            likedIds.remove(at: current)
        } else {
            likedIds.append(id)
        }
        let likesToSend = likedIds
        likesService.saveLikes(likesToSend) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isSavingLike = false
                switch result {
                case .success(let profile):
                    self.likedIds = profile.likes
                    self.view?.updateNft(at: index, isLiked: profile.likes.contains(id), isInCart: self.cartIds.contains(id))
                case .failure:
                    self.restore(id, wasIncluded: wasLiked, in: &self.likedIds)
                    self.view?.showError(self.makeErrorModel { [weak self] in
                        self?.didTapLike(id: id)
                    })
                }
            }
        }
    }

    func didTapCart(id: String) {
        guard state == .data, !isSavingCart, let index = nfts.firstIndex(where: { $0.id == id }) else { return }
        isSavingCart = true
        orderService.loadNftIds { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                DispatchQueue.main.async {
                    self.isSavingCart = false
                    self.view?.showError(self.makeErrorModel { [weak self] in
                        self?.didTapCart(id: id)
                    })
                }
            case .success(var ids):
                if let found = ids.firstIndex(of: id) {
                    ids.remove(at: found)
                } else {
                    ids.append(id)
                }
                self.orderService.saveNftIds(ids) { [weak self] saveResult in
                    DispatchQueue.main.async {
                        guard let self else { return }
                        self.isSavingCart = false
                        switch saveResult {
                        case .success(let saved):
                            self.cartIds = saved
                            self.view?.updateNft(at: index, isLiked: self.likedIds.contains(id), isInCart: saved.contains(id))
                        case .failure:
                            self.view?.showError(self.makeErrorModel { [weak self] in
                                self?.didTapCart(id: id)
                            })
                        }
                    }
                }
            }
        }
    }
    
    private func restore(_ id: String, wasIncluded: Bool, in list: inout [String]) {
        if wasIncluded {
            if !list.contains(id) {
                list.append(id)
            }
        } else {
            list.removeAll { $0 == id }
        }
    }

    private func makeHeaderModel() -> CollectionHeaderModel {
        CollectionHeaderModel(
            cover: collection.cover,
            name: collection.name,
            authorName: collection.author,
            authorURL: authorURL(from: collection.author),
            description: collection.description
        )
    }

    private func authorURL(from author: String) -> URL? {
        guard let url = URL(string: author), let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else {
            return nil
        }
        return url
    }

    private func makeErrorModel(retry: @escaping () -> Void) -> ErrorModel {
        let message = NSLocalizedString("Error.network", comment: "")
        let actionText = NSLocalizedString("Error.repeat", comment: "")
        return ErrorModel(message: message, actionText: actionText, action: retry)
    }
}
