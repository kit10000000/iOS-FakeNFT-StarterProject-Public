import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum DtoValueType {
    case dtoString(String)
    case dtoArray([String])
}

protocol NetworkRequest {
    var endpoint: URL? { get }
    var httpMethod: HttpMethod { get }
    var dto: Dto? { get }
}

protocol Dto {
    func asDictionary() -> [String: DtoValueType]
}

// default values
extension NetworkRequest {
    var httpMethod: HttpMethod { .get }
    var dto: Encodable? { nil }
}
