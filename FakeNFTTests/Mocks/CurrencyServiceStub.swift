//
//  CurrencyServiceStub.swift
//  FakeNFT
//
//  Created by Ekaterina on 27.10.2026.
//


@testable import FakeNFT

final class CurrencyServiceStub: CurrencyService {
    var currenciesResult: Result<[Currency], Error> = .success([])
    var currencyResult: Result<Currency, Error> = .success(
        Currency(id: "0", title: "Bitcoin", name: "BTC", image: nil)
    )

    func getCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
        completion(currenciesResult)
    }
    func getCurrency(id: String, completion: @escaping (Result<Currency, Error>) -> Void) {
        completion(currencyResult)
    }
}