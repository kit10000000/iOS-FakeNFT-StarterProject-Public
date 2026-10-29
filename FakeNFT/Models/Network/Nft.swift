import Foundation

struct Nft: Decodable {
    let id: String
    let name: String
    let images: [URL]
    let rating: Int
    let price: Double
    let description: String
    let author: String
    let website: URL?
    init(
        id: String,
        name: String,
        images: [URL],
        rating: Int,
        price: Double,
        description: String,
        author: String,
        website: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.images = images
        self.rating = rating
        self.price = price
        self.description = description
        self.author = author
        self.website = website
    }
}
