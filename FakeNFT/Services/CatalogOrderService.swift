//
//  CatalogOrderService.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 19.10.2026.
//

import Foundation

typealias CatalogOrderCompletion = (Result<[String], Error>) -> Void

protocol CatalogOrderService {
    func loadNftIds(completion: @escaping CatalogOrderCompletion)
    func saveNftIds(_ ids: [String], completion: @escaping CatalogOrderCompletion)
}

final class CatalogOrderServiceImpl: CatalogOrderService {

    private let networkClient: NetworkClient
    private let completionQueue = DispatchQueue(label: "catalog.order", qos: .userInitiated)

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadNftIds(completion: @escaping CatalogOrderCompletion) {
        let request = GetCatalogOrderRequest()
        networkClient.send(request: request, type: CatalogOrderResponse.self, completionQueue: completionQueue) { result in
            switch result {
            case .success(let order):
                completion(.success(order.nfts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func saveNftIds(_ ids: [String], completion: @escaping CatalogOrderCompletion) {
        let items: [(String, String)]
        if ids.isEmpty {
            items = [("nfts", "")]
        } else {
            items = ids.map { ("nfts", $0) }
        }
        let body = FormURLEncoder.encode(items)
        let request = UpdateCatalogOrderRequest(httpBody: body)
        networkClient.send(request: request, type: CatalogOrderResponse.self, completionQueue: completionQueue) { result in
            switch result {
            case .success(let order):
                completion(.success(order.nfts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
