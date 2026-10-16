//
//  CatalogPresenter.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 12.10.2026.
//

import Foundation

protocol CatalogView: AnyObject {
    func showCollections(_ collections: [NftCollection])
    func openCollection(_ collection: NftCollection, nfts: [Nft])
}

final class CatalogPresenter {

    weak var view: CatalogView?

    private var collections: [NftCollection] = []
    private var nftsByCollectionId: [String: [Nft]] = [:]

    func viewDidLoad() {
        let demo = DemoCatalog.load()
        collections = demo.collections
        nftsByCollectionId = demo.nftsByCollectionId
        view?.showCollections(collections)
    }

    func didSelectCollection(at index: Int) {
        guard collections.indices.contains(index) else { return }
        let collection = collections[index]
        let nfts = nftsByCollectionId[collection.id] ?? []
        view?.openCollection(collection, nfts: nfts)
    }
    
    func sortByName() {
        collections.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        view?.showCollections(collections)
    }

    func sortByNftCount() {
        collections.sort { $0.nfts.count > $1.nfts.count }
        view?.showCollections(collections)
    }
}

private enum DemoCatalog {

    private static let coverFolder = "https://code.s3.yandex.net/Mobile/iOS/NFT/%D0%9E%D0%B1%D0%BB%D0%BE%D0%B6%D0%BA%D0%B8_%D0%BA%D0%BE%D0%BB%D0%BB%D0%B5%D0%BA%D1%86%D0%B8%D0%B9/"
    private static let authorSite = "https://ya.ru"

    static func load() -> (collections: [NftCollection], nftsByCollectionId: [String: [Nft]]) {
        let peach = makeCollection(
            id: "peach",
            name: "Peach",
            description: "Персиковый — как облака над закатным солнцем в океане. В этой коллекции совмещены трогательная нежность и живая игривость сказочных эфирных зверей.",
            cards: [
                Card(name: "Archie", rating: 5),
                Card(name: "Ruby", rating: 4),
                Card(name: "Nacho", rating: 3),
                Card(name: "Biscuit", rating: 5),
                Card(name: "Daisy", rating: 2),
                Card(name: "Susan", rating: 4),
                Card(name: "Oreo", rating: 1),
                Card(name: "Pixi", rating: 5),
                Card(name: "Zoe", rating: 3),
                Card(name: "Tater", rating: 4)
            ]
        )
        let blue = makeCollection(
            id: "blue",
            name: "Blue",
            description: "Синяя коллекция. Сетка показывает локальные карточки.",
            cards: [
                Card(name: "Bonnie", rating: 5),
                Card(name: "Diana", rating: 4),
                Card(name: "Ollie", rating: 3)
            ]
        )
        let brown = makeCollection(
            id: "brown",
            name: "Brown",
            description: "Коричневая коллекция. Обложка и карточки берутся по готовым адресам картинок.",
            cards: [
                Card(name: "Charlie", rating: 5),
                Card(name: "Emma", rating: 4),
                Card(name: "Stella", rating: 3),
                Card(name: "Zeus", rating: 5),
                Card(name: "Rosie", rating: 2),
                Card(name: "Toast", rating: 4)
            ]
        )
        let collections = [peach.collection, blue.collection, brown.collection]
        let nftsByCollectionId = [
            peach.collection.id: peach.nfts,
            blue.collection.id: blue.nfts,
            brown.collection.id: brown.nfts
        ]
        return (collections, nftsByCollectionId)
    }

    private struct Card {
        let name: String
        let rating: Int
    }

    private static func makeCollection(
        id: String,
        name: String,
        description: String,
        cards: [Card]
    ) -> (collection: NftCollection, nfts: [Nft]) {
        var nfts: [Nft] = []
        for card in cards {
            nfts.append(makeNft(collectionId: id, folder: name, name: card.name, rating: card.rating))
        }
        var ids: [String] = []
        for nft in nfts {
            ids.append(nft.id)
        }
        let collection = NftCollection(
            id: id,
            name: name,
            cover: url(coverFolder + name + ".png"),
            description: description,
            author: authorSite,
            nfts: ids
        )
        return (collection, nfts)
    }

    private static func makeNft(collectionId: String, folder: String, name: String, rating: Int) -> Nft {
        let id = collectionId + "-" + name.lowercased()
        let image = "https://code.s3.yandex.net/Mobile/iOS/NFT/" + folder + "/" + name + "/1.png"
        return Nft(
            id: id,
            name: name,
            images: [url(image)],
            rating: rating,
            price: 1,
            description: name,
            author: "John Doe"
        )
    }

    private static func url(_ string: String) -> URL {
        if let url = URL(string: string) {
            return url
        }
        return URL(fileURLWithPath: "/")
    }
}
