//
//  PaymentService.swift
//  FakeNFT
//
//  Created by Ekaterina on 24.10.2026.
//

import Foundation

protocol PaymentService {
    func getPayment(currencyId: String, completion: @escaping (Result<Payment, Error>) -> Void)
}

final class PaymentServiceImpl: PaymentService {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }


    func getPayment(currencyId: String, completion: @escaping (Result<Payment, Error>) -> Void) {
        let request = PaymentRequest(currencyId: currencyId)
        networkClient.send(request: request, type: Payment.self) { result in
            switch result {
            case .success(let payment):
                completion(.success(payment))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
