//
//  CartPresenterTests.swift
//  FakeNFT
//
//  Created by Ekaterina on 15.10.2026.
//

import XCTest
@testable import FakeNFT

final class CartPresenterTests: XCTestCase {

    private var orderService: OrderServiceStub!
    private var nftService: NftServiceStub!
    private var presenter: CartPresenterImpl!
    private var view: CartViewControllerSpy!
    private var storage: CartStorageStub!

    override func setUp() {
        super.setUp()

        orderService = OrderServiceStub()
        orderService.result = .success(Order(id: "1", nfts: ["1", "2"]))

        nftService = NftServiceStub()
        nftService.nfts = [
            "1": Nft(id: "1", name: "First",  images: [], rating: 3, price: 2, description: "", author: "a"),
            "2": Nft(id: "2", name: "Second", images: [], rating: 5, price: 3, description: "", author: "b")
        ]

        storage = CartStorageStub()

        presenter = CartPresenterImpl(
            orderService: orderService,
            nftService: nftService,
            storage: storage
        )

        view = CartViewControllerSpy()
        presenter.view = view
    }

    override func tearDown() {
        orderService = nil
        nftService = nil
        presenter = nil
        view = nil
        super.tearDown()
    }

    func testSuccessCallsDisplay() {
        // Given
        let exp = expectation(description: "display")
        view.onEvent = { exp.fulfill() }

        // When
        presenter.viewWillAppear()

        // Then
        wait(for: [exp], timeout: 1)
        XCTAssertTrue(view.displayCalled)
        XCTAssertTrue(presenter.nftCartViewModelArray.count == 2)
    }

    func testEmptyStateOnEmptyOrder() {
        // Given
        orderService.result = .success(Order(id: "1", nfts: []))

        // When
        presenter.viewWillAppear()

        // Then
        XCTAssertTrue(view.showEmptyStateCalled)
        XCTAssertFalse(view.displayCalled)
    }

    func testShowErrorOnFailure() {
        // Given
        orderService.result = .failure(NetworkClientError.urlSessionError)

        // When
        presenter.viewWillAppear()

        // Then
        XCTAssertTrue(view.showErrorCalled)
    }

    func testSortByPrice() {
        // Given
        storage.sortOption = .price
        let exp = expectation(description: "display")
        view.onEvent = { exp.fulfill() }

        // When
        presenter.viewWillAppear()

        // Then
        wait(for: [exp], timeout: 1)
        XCTAssertTrue(presenter.nftCartViewModelArray.first?.price == 2)  // дешёвый первый
    }

    func testDeleteReducesCount() {
        // Given
        let loadExp = expectation(description: "loaded")
        view.onEvent = { loadExp.fulfill() }
        presenter.viewWillAppear()
        wait(for: [loadExp], timeout: 1)

        let deleteExp = expectation(description: "deleted")
        view.onEvent = { deleteExp.fulfill() }

        // When
        presenter.didTapConfirmDelete(nftId: 0)

        // Then
        wait(for: [deleteExp], timeout: 1)
        XCTAssertTrue(presenter.nftCartViewModelArray.count == 1)
    }

    func testDeleteLastShowsEmpty() {
        // Given
        orderService.result = .success(Order(id: "1", nfts: ["1"]))
        let loadExp = expectation(description: "loaded")
        view.onEvent = { loadExp.fulfill() }
        presenter.viewWillAppear()
        wait(for: [loadExp], timeout: 1)

        let deleteExp = expectation(description: "deleted")
        view.onEvent = { deleteExp.fulfill() }

        // When
        presenter.didTapConfirmDelete(nftId: 0)

        // Then
        wait(for: [deleteExp], timeout: 1)
        XCTAssertTrue(view.showEmptyStateCalled)
        XCTAssertTrue(presenter.nftCartViewModelArray.isEmpty)
    }
}
