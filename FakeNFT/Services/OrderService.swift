//
//  OrderService.swift
//  FakeNFT
//
//  Created by Ekaterina on 12.10.2026.
//

import Foundation

protocol OrderService {
    func getOrder(id: String, completion: @escaping (Result<Order, Error>) -> Void)
    func sendOrderPutRequest(
        nfts: [String],
        completion: @escaping (Result<Order, Error>)-> Void
    )
}

final class OrderServiceImpl: OrderService {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func getOrder(id: String, completion: @escaping (Result<Order, Error>) -> Void) {
        let request = OrderRequest(id: id)
        networkClient.send(request: request, type: Order.self) { result in
            switch result {
            case .success(let order):
                completion(.success(order))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func sendOrderPutRequest(
        nfts: [String],
        completion: @escaping (Result<Order, Error>)-> Void
    ) {
        let dto = OrderPutDtoObject(nfts: nfts)
        let request = OrderPutRequest(dto: dto)
        networkClient.send(request: request, type: Order.self) { result in
            switch result {
            case .success(let putResponse):
                completion(.success(putResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
