//
//  OrderServiceMock.swift
//  FakeNFT
//
//  Created by Ekaterina on 12.10.2026.
//
#if DEBUG
import Foundation

final class OrderServiceMockImpl: OrderService {

    private var result: Result<Order, Error>

    init(result: Result<Order, Error>) {
        self.result = result
    }

    func getOrder(id: String, completion: @escaping (Result<Order, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            switch self.result {
            case .success(let order):
                completion(.success(order))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
#endif
