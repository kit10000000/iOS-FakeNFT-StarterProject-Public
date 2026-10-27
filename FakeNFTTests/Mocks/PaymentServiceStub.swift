//
//  PaymentServiceStub.swift
//  FakeNFT
//
//  Created by Ekaterina on 27.10.2026.
//


@testable import FakeNFT

final class PaymentServiceStub: PaymentService {
    var result: Result<Payment, Error> = .success(Payment(id: "0", orderId: "1", success: true))

    func getPayment(currencyId: String, completion: @escaping (Result<Payment, Error>) -> Void) {
        completion(result)
    }
}