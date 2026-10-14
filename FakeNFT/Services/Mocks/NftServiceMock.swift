//
//  NftServiceMock.swift
//  FakeNFT
//
//  Created by Ekaterina on 14.10.2026.
//


#if DEBUG
import Foundation

final class NftServiceMock: NftService {

    func loadNft(id: String, completion: @escaping NftCompletion) {
        let nft = Nft(
            id: id,
            name: "NFT \(id.prefix(4))",
            images: [URL(string: "https://code.s3.yandex.net/landings-v2-ios-developer/space.png")!],
            rating: Int.random(in: 0...5),
            price:  1.78,
            description: "",
            author: ""
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(.success(nft))
        }
    }
}
#endif
