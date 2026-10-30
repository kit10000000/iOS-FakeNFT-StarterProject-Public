//
//  CatalogPresenterTests.swift
//  FakeNFTTests
//
//  Created by Dmitrii Pogonia on 22.10.2026.
//

@testable import FakeNFT
import XCTest

final class CatalogPresenterTests: XCTestCase {

    private var defaults: UserDefaults!
    private var storage: CatalogSortStorageImpl!
    private var service: FakeCollectionService!
    private var view: CatalogViewSpy!
    private var presenter: CatalogPresenter!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "CatalogPresenterTests")
        defaults?.removePersistentDomain(forName: "CatalogPresenterTests")
        storage = CatalogSortStorageImpl(defaults: defaults ?? .standard)
        service = FakeCollectionService()
        view = CatalogViewSpy()
        presenter = CatalogPresenter(collectionService: service, sortStorage: storage)
        presenter.view = view
    }

    func testLoadSuccessAppliesCountSort() {
        service.result = .success([
            makeCollection(name: "Ann", ids: ["1"]),
            makeCollection(name: "Zed", ids: ["1", "2", "3"])
        ])
        presenter.viewDidLoad()
        waitMain()
        XCTAssertEqual(view.collections.map(\.name), ["Zed", "Ann"])
        XCTAssertTrue(view.errors.isEmpty)
    }

    func testLoadFailureShowsError() {
        service.result = .failure(NetworkClientError.parsingError)
        presenter.viewDidLoad()
        waitMain()
        XCTAssertTrue(view.collections.isEmpty)
        XCTAssertEqual(view.errors.count, 1)
    }

    func testRetryLoadsAgain() {
        service.result = .failure(NetworkClientError.urlSessionError)
        presenter.viewDidLoad()
        waitMain()
        XCTAssertEqual(service.loadCount, 1)
        view.errors[0].action()
        waitMain()
        XCTAssertEqual(service.loadCount, 2)
    }

    func testSortChangesOrder() {
        service.result = .success([
            makeCollection(name: "Ann", ids: ["1"]),
            makeCollection(name: "Zed", ids: ["1", "2", "3"])
        ])
        presenter.viewDidLoad()
        waitMain()
        XCTAssertEqual(view.collections.map(\.name), ["Zed", "Ann"])
        presenter.sortByName()
        XCTAssertEqual(view.collections.map(\.name), ["Ann", "Zed"])
        presenter.sortByNftCount()
        XCTAssertEqual(view.collections.map(\.name), ["Zed", "Ann"])
    }

    func testSortIsRestored() {
        presenter.sortByName()
        let nextView = CatalogViewSpy()
        let nextStorage = CatalogSortStorageImpl(defaults: defaults)
        let next = CatalogPresenter(collectionService: service, sortStorage: nextStorage)
        next.view = nextView
        service.result = .success([
            makeCollection(name: "Zed", ids: ["1", "2", "3"]),
            makeCollection(name: "Ann", ids: ["1"])
        ])
        next.viewDidLoad()
        waitMain()
        XCTAssertEqual(nextView.collections.map(\.name), ["Ann", "Zed"])
    }

    private func waitMain() {
        let expectation = expectation(description: "main")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    private func makeCollection(name: String, ids: [String]) -> NftCollection {
        NftCollection(
            id: name,
            name: name,
            cover: URL(string: "https://example.com/\(name).png") ?? URL(fileURLWithPath: "/"),
            description: "",
            author: "https://example.com",
            nfts: ids
        )
    }
}

private final class FakeCollectionService: CollectionService {
    var result: Result<[NftCollection], Error> = .success([])
    var loadCount = 0

    func loadCollections(completion: @escaping CollectionListCompletion) {
        loadCount += 1
        completion(result)
    }
}

private final class CatalogViewSpy: CatalogView {
    var collections: [NftCollection] = []
    var errors: [ErrorModel] = []

    func showLoading() {}
    func hideLoading() {}
    func showError(_ model: ErrorModel) {
        errors.append(model)
    }
    func setInteractionEnabled(_ isEnabled: Bool) {}
    func showCollections(_ collections: [NftCollection]) {
        self.collections = collections
    }
    func openCollection(_ collection: NftCollection) {}
}
