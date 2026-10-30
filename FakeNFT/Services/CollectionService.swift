//
//  CollectionService.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 16.10.2026.
//

import Foundation

typealias CollectionListCompletion = (Result<[NftCollection], Error>) -> Void

protocol CollectionService {
    func loadCollections(completion: @escaping CollectionListCompletion)
}

final class CollectionServiceImpl: CollectionService {

    private let networkClient: NetworkClient
    private let completionQueue = DispatchQueue(label: "catalog.collections", qos: .userInitiated)

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadCollections(completion: @escaping CollectionListCompletion) {
        let request = CollectionsRequest()
        networkClient.send(request: request, type: [NftCollection].self, completionQueue: completionQueue) { result in
            completion(result)
        }
    }
}
