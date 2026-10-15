//
//  OrderServiceStub.swift
//  FakeNFT
//
//  Created by Ekaterina on 15.10.2026.
//


@testable import FakeNFT

final class OrderServiceStub: OrderService {
    var result: Result<Order, Error> = .success(Order(id: "1", nfts: []))

    func getOrder(id: String, completion: @escaping (Result<Order, Error>) -> Void) {
        completion(result)
    }
}
