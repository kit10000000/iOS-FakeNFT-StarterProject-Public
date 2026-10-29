//
//  CatalogPresenter.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 12.10.2026.
//

import Foundation

protocol CatalogView: AnyObject {
    func showLoading()
    func hideLoading()
    func showError(_ model: ErrorModel)
    func setInteractionEnabled(_ isEnabled: Bool)
    func showCollections(_ collections: [NftCollection])
    func openCollection(_ collection: NftCollection)
}

final class CatalogPresenter {

    weak var view: CatalogView?

    private enum State {
        case loading
        case data
        case failed
    }

    private let collectionService: CollectionService
    private let sortStorage: CatalogSortStorage
    private var collections: [NftCollection] = []
    private var state: State = .loading
    private var isOpeningCollection = false

    init(collectionService: CollectionService, sortStorage: CatalogSortStorage) {
        self.collectionService = collectionService
        self.sortStorage = sortStorage
    }

    func viewDidLoad() {
        loadCollections()
    }

    func loadCollections() {
        state = .loading
        view?.setInteractionEnabled(false)
        view?.showLoading()
        collectionService.loadCollections { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let collections):
                let sorted = self.sorted(collections)
                DispatchQueue.main.async {
                    self.collections = sorted
                    self.state = .data
                    self.view?.hideLoading()
                    self.view?.setInteractionEnabled(true)
                    self.view?.showCollections(sorted)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.state = .failed
                    self.view?.hideLoading()
                    self.view?.setInteractionEnabled(true)
                    self.view?.showError(self.makeErrorModel(error) { [weak self] in
                        self?.loadCollections()
                    })
                }
            }
        }
    }

    func viewWillAppear() {
        isOpeningCollection = false
    }

    func didSelectCollection(at index: Int) {
        guard state == .data, !isOpeningCollection, collections.indices.contains(index) else { return }
        isOpeningCollection = true
        let collection = collections[index]
        view?.openCollection(collection)
    }

    func sortByName() {
        sortStorage.sort = .byName
        collections = sorted(collections)
        view?.showCollections(collections)
    }

    func sortByNftCount() {
        sortStorage.sort = .byNftCount
        collections = sorted(collections)
        view?.showCollections(collections)
    }

    private func sorted(_ collections: [NftCollection]) -> [NftCollection] {
        switch sortStorage.sort {
        case .byName:
            return collections.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .byNftCount:
            return collections.sorted { $0.nfts.count > $1.nfts.count }
        }
    }

    private func makeErrorModel(_ error: Error, retry: @escaping () -> Void) -> ErrorModel {
        let message: String
        if error is NetworkClientError {
            message = NSLocalizedString("Error.network", comment: "")
        } else {
            message = NSLocalizedString("Error.unknown", comment: "")
        }
        let actionText = NSLocalizedString("Error.repeat", comment: "")
        return ErrorModel(message: message, actionText: actionText, action: retry)
    }
}
