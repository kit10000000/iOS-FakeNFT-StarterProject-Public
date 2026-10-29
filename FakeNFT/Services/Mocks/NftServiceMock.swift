//
//  NftServiceMock.swift
//  FakeNFT
//
//  Created by Ekaterina on 14.10.2026.
//

#if DEBUG
import Foundation

final class NftServiceMockImpl: NftService {

    func loadNft(id: String, completion: @escaping NftCompletion) {
        let nft = Nft(
            id: id,
            name: "NFT \(id.prefix(4))",
            images: [URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTIvzxwiZ8YpkZeQnJn6YFthVw73X8lVRGP1aQGcFlmlw&s=10")!],
            rating: Int.random(in: 0...5),
            price:  Double.random(in: 0.5...5),
            description: "",
            author: ""
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.mockDelay) {
            completion(.success(nft))
        }
    }
}

private extension NftServiceMockImpl {
    enum Constants {
        static let mockDelay: TimeInterval = 0.3
    }
}
#endif
