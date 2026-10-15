//
//  NftServiceStub.swift
//  FakeNFT
//
//  Created by Ekaterina on 15.10.2026.
//


@testable import FakeNFT

final class NftServiceStub: NftService {
    var nfts: [String: Nft] = [:]

    func loadNft(id: String, completion: @escaping NftCompletion) {
        if let nft = nfts[id] {
            completion(.success(nft))
        } else {
            completion(.failure(NetworkClientError.urlSessionError))
        }
    }
}
