//
//  CurrencyService.swift
//  FakeNFT
//
//  Created by Ekaterina on 24.10.2026.
//

import Foundation

protocol CurrencyService {
    func getCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void)
    func getCurrency(id: String, completion: @escaping (Result<Currency, Error>) -> Void)
}

final class CurrencyServiceImpl: CurrencyService {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func getCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
        let request = CurrenciesRequest()
        networkClient.send(request: request, type: [Currency].self) { result in
            switch result {
            case .success(let currencies):
                completion(.success(currencies))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getCurrency(id: String, completion: @escaping (Result<Currency, Error>) -> Void) {
        let request = CurrencyRequest(id: id)
        networkClient.send(request: request, type: Currency.self) { result in
            switch result {
            case .success(let currency):
                completion(.success(currency))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
