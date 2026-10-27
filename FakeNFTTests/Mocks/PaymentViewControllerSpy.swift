//
//  PaymentViewControllerSpy.swift
//  FakeNFT
//
//  Created by Ekaterina on 27.10.2026.
//


import UIKit
@testable import FakeNFT

final class PaymentViewControllerSpy: PaymentViewControllerProtocol {
    var activityIndicator = UIActivityIndicatorView()

    var displayCalled = false
    var showErrorCalled = false
    var showPaymentSuccessCalled = false
    var payButtonEnabled: Bool?

    func display()                       { displayCalled = true }
    func showLoading()                   { }
    func hideLoading()                   { }
    func showError(_ model: ErrorModel)  { showErrorCalled = true }
    func setPayButtonEnabled(_ isEnabled: Bool) { payButtonEnabled = isEnabled }
    func showPaymentSuccess()            { showPaymentSuccessCalled = true }
}