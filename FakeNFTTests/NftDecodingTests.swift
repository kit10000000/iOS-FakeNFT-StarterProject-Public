//
//  NftDecodingTests.swift
//  FakeNFTTests
//
//  Created by Dmitrii Pogonia on 28.10.2026.
//

import XCTest
@testable import FakeNFT

final class NftDecodingTests: XCTestCase {

    func testDecodesWebsiteURL() throws {
        let nft = try decode(website: "\"https://example.com/author\"")
        XCTAssertEqual(nft.website, URL(string: "https://example.com/author"))
    }

    func testDecodesNullWebsiteAsNil() throws {
        let nft = try decode(website: "null")
        XCTAssertNil(nft.website)
    }

    func testDecodesMissingWebsiteAsNil() throws {
        let json = """
        {
          "id": "1",
          "name": "Biscuit",
          "images": ["https://example.com/biscuit.png"],
          "rating": 3,
          "price": 1.0,
          "description": "dog",
          "author": "John Doe"
        }
        """
        let nft = try JSONDecoder().decode(Nft.self, from: Data(json.utf8))
        XCTAssertNil(nft.website)
        XCTAssertEqual(nft.author, "John Doe")
    }

    private func decode(website: String) throws -> Nft {
        let json = """
        {
          "id": "1",
          "name": "Biscuit",
          "images": ["https://example.com/biscuit.png"],
          "rating": 3,
          "price": 1.0,
          "description": "dog",
          "author": "John Doe",
          "website": \(website)
        }
        """
        return try JSONDecoder().decode(Nft.self, from: Data(json.utf8))
    }
}
