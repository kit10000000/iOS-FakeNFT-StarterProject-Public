//
//  CartViewControllerSpy.swift
//  FakeNFT
//
//  Created by Ekaterina on 15.10.2026.
//

import UIKit
@testable import FakeNFT

final class CartViewControllerSpy: CartViewControllerProtocol {

    var activityIndicator = UIActivityIndicatorView()

    var displayCalled = false
    var showEmptyStateCalled = false
    var showErrorCalled = false
    var showLoadingCalled = false
    var hideLoadingCalled = false

    var onEvent: (() -> Void)?

    func display()                  { displayCalled = true; onEvent?() }
    func showEmptyState()           { showEmptyStateCalled = true; onEvent?() }
    func showError(_ model: ErrorModel) { showErrorCalled = true; onEvent?() }
    func showLoading()              { showLoadingCalled = true }
    func hideLoading()              { hideLoadingCalled = true }
    func showPaymentScreen() {}
}
