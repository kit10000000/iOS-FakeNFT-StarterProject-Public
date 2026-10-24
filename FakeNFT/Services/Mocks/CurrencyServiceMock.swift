//
//  CurrencyServiceMock.swift
//  FakeNFT
//
//  Created by Ekaterina on 24.10.2026.
//

#if DEBUG
import Foundation

final class CurrencyServiceMockImpl: CurrencyService {

    private var result: Result<[Currency], Error>

    init(result: Result<[Currency], Error>) {
        self.result = result
    }

    func getCurrency(id: String, completion: @escaping (Result<Currency, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.mockDelay) {
            switch self.result {
            case .success(let currencies):
                let currency = currencies.first(where: { $0.id == id })
                completion(.success(currency!))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.mockDelay) {
            switch self.result {
            case .success(let currencies):
                completion(.success(currencies))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private extension CurrencyServiceMockImpl {
    enum Constants {
        static let mockDelay: TimeInterval = 1.5
    }
}

extension Currency {
    static let mockList: [Currency] = [
        Currency(id: "cf087b9e-35cd-58dc-a87d-3d2c2212d804", title: "Bitcoin",   name: "BTC",
                 image: "https://whoami12585.pythonanywhere.com/static/currencies/BTC.png"),
        Currency(id: "8caa705d-11fb-50d3-a51a-5d8db5cb3199", title: "Dogecoin",  name: "DOGE",
                 image: "https://whoami12585.pythonanywhere.com/static/currencies/DOGE.png"),
        Currency(id: "9491e6dd-f4ae-50e2-87ba-9060a2153edb", title: "Tether",    name: "USDT",
                 image: "https://whoami12585.pythonanywhere.com/static/currencies/USDT.png"),
        Currency(id: "3e610467-f006-5fb7-9f10-5ab4044aae81", title: "ApeCoin",   name: "APE",
                 image: "https://whoami12585.pythonanywhere.com/static/currencies/APE.png"),
        Currency(id: "7a02a06b-1233-5d3e-9fc7-affae44c4e65", title: "Ethereum",  name: "ETH",
                 image: "https://whoami12585.pythonanywhere.com/static/currencies/ETH.png"),
        Currency(id: "c27971ff-affd-5e15-9af6-e531dd606ab2", title: "Solana",    name: "SOL",
                 image: "https://whoami12585.pythonanywhere.com/static/currencies/SOL.png"),
        Currency(id: "4438fc49-385e-5ab4-a1f7-33ff448a4871", title: "Cardano",   name: "ADA",
                 image: "https://whoami12585.pythonanywhere.com/static/currencies/ADA.png"),
        Currency(id: "5d126c01-3897-5ece-bab4-d6c116516d04", title: "Shiba Inu", name: "SHIB",
                 image: "https://whoami12585.pythonanywhere.com/static/currencies/SHIB.png")
    ]
}
#endif

