//
//  CollectionPresenterTests.swift
//  FakeNFTTests
//
//  Created by Dmitrii Pogonia on 25.10.2026.
//

@testable import FakeNFT
import XCTest

final class CollectionPresenterTests: XCTestCase {

    func testNftsStayInCollectionOrder() {
        let nftService = FakeNftService()
        nftService.delayIds = ["late"]
        nftService.results = [
            "late": .success(makeNft(id: "late", name: "Late")),
            "early": .success(makeNft(id: "early", name: "Early"))
        ]
        let view = CollectionViewSpy()
        let presenter = makePresenter(
            nftIds: ["late", "early"],
            nftService: nftService,
            likes: FakeLikesService(likes: []),
            order: FakeOrderService(ids: []),
            view: view
        )
        presenter.viewDidLoad()
        waitUntil { view.nfts.map(\.id) == ["late", "early"] }
        XCTAssertEqual(view.nfts.map(\.name), ["Late", "Early"])
    }

    func testLikeSendsPreviousListPlusNewId() {
        let likes = FakeLikesService(likes: ["keep"])
        let view = CollectionViewSpy()
        let presenter = makePresenter(
            nftIds: ["new"],
            nftService: readyNftService(["new"]),
            likes: likes,
            order: FakeOrderService(ids: []),
            view: view
        )
        presenter.viewDidLoad()
        waitUntil { view.nfts.map(\.id) == ["new"] }
        presenter.didTapLike(id: "new")
        waitMain()
        XCTAssertEqual(likes.saved, [["keep", "new"]])
    }

    func testUnlikeSendsListWithoutId() {
        let likes = FakeLikesService(likes: ["keep", "new"])
        let view = CollectionViewSpy()
        let presenter = makePresenter(
            nftIds: ["new"],
            nftService: readyNftService(["new"]),
            likes: likes,
            order: FakeOrderService(ids: []),
            view: view
        )
        presenter.viewDidLoad()
        waitUntil { view.nfts.map(\.id) == ["new"] }
        presenter.didTapLike(id: "new")
        waitMain()
        XCTAssertEqual(likes.saved, [["keep"]])
    }

    func testOrderSaveKeepsForeignIds() {
        let order = FakeOrderService(ids: ["foreign"])
        let view = CollectionViewSpy()
        let presenter = makePresenter(
            nftIds: ["new"],
            nftService: readyNftService(["new"]),
            likes: FakeLikesService(likes: []),
            order: order,
            view: view
        )
        presenter.viewDidLoad()
        waitUntil { view.nfts.map(\.id) == ["new"] }
        presenter.didTapCart(id: "new")
        waitMain()
        XCTAssertEqual(order.saved, [["foreign", "new"]])
    }

    func testOrderRemovalKeepsOtherIds() {
        let order = FakeOrderService(ids: ["foreign", "new"])
        let view = CollectionViewSpy()
        let presenter = makePresenter(
            nftIds: ["new"],
            nftService: readyNftService(["new"]),
            likes: FakeLikesService(likes: []),
            order: order,
            view: view
        )
        presenter.viewDidLoad()
        waitUntil { view.nfts.map(\.id) == ["new"] }
        presenter.didTapCart(id: "new")
        waitMain()
        XCTAssertEqual(order.saved, [["foreign"]])
    }

    func testLikeErrorRestoresCellAndIgnoresSecondTap() {
        let likes = FakeLikesService(likes: ["keep"])
        likes.hold = true
        let view = CollectionViewSpy()
        let presenter = makePresenter(
            nftIds: ["new"],
            nftService: readyNftService(["new"]),
            likes: likes,
            order: FakeOrderService(ids: []),
            view: view
        )
        presenter.viewDidLoad()
        waitUntil { view.nfts.map(\.id) == ["new"] }
        presenter.didTapLike(id: "new")
        waitMain()
        presenter.didTapLike(id: "new")
        waitMain()
        XCTAssertEqual(likes.saved.count, 1)
        likes.failHeld()
        waitMain()
        XCTAssertEqual(view.updates.last?.isLiked, false)
        XCTAssertEqual(likes.saved.count, 1)
    }

    func testCartErrorRestoresCell() {
        let order = FakeOrderService(ids: ["foreign"])
        order.holdSave = true
        let view = CollectionViewSpy()
        let presenter = makePresenter(
            nftIds: ["new"],
            nftService: readyNftService(["new"]),
            likes: FakeLikesService(likes: []),
            order: order,
            view: view
        )
        presenter.viewDidLoad()
        waitUntil { view.nfts.map(\.id) == ["new"] }
        presenter.didTapCart(id: "new")
        waitMain()
        presenter.didTapCart(id: "new")
        waitMain()
        XCTAssertEqual(order.saved.count, 1)
        order.failHeld()
        waitMain()
        XCTAssertEqual(view.updates.last?.isInCart, false)
    }

    private func makePresenter(
        nftIds: [String],
        nftService: NftService,
        likes: LikesService,
        order: CatalogOrderService,
        view: CollectionViewSpy
    ) -> CollectionPresenter {
        let collection = NftCollection(
            id: "collection",
            name: "Collection",
            cover: URL(string: "https://example.com/cover.png") ?? URL(fileURLWithPath: "/"),
            description: "",
            author: "https://example.com",
            nfts: nftIds
        )
        let presenter = CollectionPresenter(
            collection: collection,
            nftService: nftService,
            likesService: likes,
            orderService: order
        )
        presenter.view = view
        return presenter
    }

    private func readyNftService(_ ids: [String]) -> FakeNftService {
        let service = FakeNftService()
        var results: [String: Result<Nft, Error>] = [:]
        for id in ids {
            results[id] = .success(makeNft(id: id, name: id))
        }
        service.results = results
        return service
    }

    private func makeNft(id: String, name: String) -> Nft {
        Nft(
            id: id,
            name: name,
            images: [URL(string: "https://example.com/\(id).png") ?? URL(fileURLWithPath: "/")],
            rating: 1,
            price: 1,
            description: "",
            author: "https://example.com"
        )
    }

    private func waitMain() {
        let expectation = expectation(description: "main")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    private func waitUntil(timeout: TimeInterval = 1, _ condition: @escaping () -> Bool) {
        let expectation = expectation(description: "until")
        let deadline = Date().addingTimeInterval(timeout)
        func poll() {
            if condition() || Date() > deadline {
                expectation.fulfill()
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: poll)
        }
        poll()
        wait(for: [expectation], timeout: timeout + 0.5)
    }
}

private final class FakeNftService: NftService {
    var results: [String: Result<Nft, Error>] = [:]
    var delayIds: Set<String> = []

    func loadNft(id: String, completion: @escaping NftCompletion) {
        let result = results[id] ?? .failure(NetworkClientError.parsingError)
        if delayIds.contains(id) {
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.05) {
                completion(result)
            }
        } else {
            completion(result)
        }
    }
}

private final class FakeLikesService: LikesService {
    var likes: [String]
    var saved: [[String]] = []
    var hold = false
    private var held: ProfileCompletion?

    init(likes: [String]) {
        self.likes = likes
    }

    func loadProfile(completion: @escaping ProfileCompletion) {
        completion(.success(profile(likes)))
    }

    func saveLikes(_ likes: [String], completion: @escaping ProfileCompletion) {
        saved.append(likes)
        if hold {
            held = completion
            return
        }
        self.likes = likes
        completion(.success(profile(likes)))
    }

    func failHeld() {
        held?(.failure(NetworkClientError.urlSessionError))
        held = nil
    }

    private func profile(_ likes: [String]) -> UserProfile {
        UserProfile(name: "", avatar: "", description: "", website: "", nfts: [], likes: likes, id: "1")
    }
}

private final class FakeOrderService: CatalogOrderService {
    var ids: [String]
    var saved: [[String]] = []
    var holdSave = false
    private var held: CatalogOrderCompletion?

    init(ids: [String]) {
        self.ids = ids
    }

    func loadNftIds(completion: @escaping CatalogOrderCompletion) {
        completion(.success(ids))
    }

    func saveNftIds(_ ids: [String], completion: @escaping CatalogOrderCompletion) {
        saved.append(ids)
        if holdSave {
            held = completion
            return
        }
        self.ids = ids
        completion(.success(ids))
    }

    func failHeld() {
        held?(.failure(NetworkClientError.urlSessionError))
        held = nil
    }
}

private final class CollectionViewSpy: CollectionView {
    var nfts: [Nft] = []
    var updates: [(index: Int, isLiked: Bool, isInCart: Bool)] = []
    var errors: [ErrorModel] = []

    func showLoading() {}
    func hideLoading() {}
    func showError(_ model: ErrorModel) {
        errors.append(model)
    }
    func setGridInteractionEnabled(_ isEnabled: Bool) {}
    func showCollection(_ header: CollectionHeaderModel) {}
    func showNfts(_ nfts: [Nft], likedIds: Set<String>, cartIds: Set<String>) {
        self.nfts = nfts
    }
    func updateNft(at index: Int, isLiked: Bool, isInCart: Bool) {
        updates.append((index, isLiked, isInCart))
    }
    func openAuthorWebsite(_ url: URL) {}
    func openNft(with id: String) {}
}
