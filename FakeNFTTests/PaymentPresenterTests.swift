//
//  PaymentPresenterTests.swift
//  FakeNFT
//
//  Created by Ekaterina on 27.10.2026.
//

import XCTest
@testable import FakeNFT

final class PaymentPresenterTests: XCTestCase {

    private var currencyService: CurrencyServiceStub!
    private var paymentService: PaymentServiceStub!
    private var orderService: OrderServiceStub!
    private var presenter: PaymentPresenterImpl!
    private var view: PaymentViewControllerSpy!

    private let currencies = [
        Currency(id: "0", title: "Bitcoin",  name: "BTC",  image: nil),
        Currency(id: "1", title: "Dogecoin", name: "DOGE", image: nil)
    ]

    override func setUp() {
        super.setUp()
        currencyService = CurrencyServiceStub()
        currencyService.currenciesResult = .success(currencies)
        paymentService = PaymentServiceStub()
        orderService = OrderServiceStub()

        presenter = PaymentPresenterImpl(
            currencyService: currencyService,
            paymentService: paymentService,
            orderService: orderService
        )
        view = PaymentViewControllerSpy()
        presenter.view = view
    }

    override func tearDown() {
        currencyService = nil
        paymentService = nil
        orderService = nil
        presenter = nil
        view = nil
        super.tearDown()
    }

    func testViewDidLoadSuccessPopulatesAndDisplays() {
        // Given
        currencyService.currenciesResult = .success(currencies)

        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertTrue(view.displayCalled)
        XCTAssertEqual(presenter.currencyViewModelArray.count, 2)
    }

    func testViewDidLoadFailureShowsError() {
        // Given
        currencyService.currenciesResult = .failure(NetworkClientError.urlSessionError)

        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertTrue(view.showErrorCalled)
        XCTAssertFalse(view.displayCalled)
    }

    func testSelectCurrencyEnablesPayButton() {
        // Given
        presenter.viewDidLoad()

        // When
        presenter.didSelectCurrency(at: 0)

        // Then
        XCTAssertEqual(view.payButtonEnabled, true)
    }

    func testPayWithoutSelectionShowsError() {
        // Given
        presenter.viewDidLoad()

        // When
        presenter.didTapPay()

        // Then
        XCTAssertTrue(view.showErrorCalled)
        XCTAssertFalse(view.showPaymentSuccessCalled)
    }

    func testPaySuccessShowsResult() {
        // Given
        paymentService.result = .success(Payment(id: "0", orderId: "1", success: true))
        presenter.viewDidLoad()
        presenter.didSelectCurrency(at: 0)

        // When
        presenter.didTapPay()

        // Then
        XCTAssertTrue(view.showPaymentSuccessCalled)
        XCTAssertFalse(view.showErrorCalled)
    }

    func testPaymentNotSuccessShowsError() {
        // Given
        paymentService.result = .success(Payment(id: "0", orderId: "1", success: false))
        presenter.viewDidLoad()
        presenter.didSelectCurrency(at: 0)

        // When
        presenter.didTapPay()

        // Then
        XCTAssertTrue(view.showErrorCalled)
        XCTAssertFalse(view.showPaymentSuccessCalled)
    }

    func testPaymentFailureShowsError() {
        // Given
        paymentService.result = .failure(NetworkClientError.urlSessionError)
        presenter.viewDidLoad()
        presenter.didSelectCurrency(at: 0)

        // When
        presenter.didTapPay()

        // Then
        XCTAssertTrue(view.showErrorCalled)
        XCTAssertFalse(view.showPaymentSuccessCalled)
    }
}
