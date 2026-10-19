//
//   LikesService.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 19.10.2026.
//

import Foundation

typealias ProfileCompletion = (Result<UserProfile, Error>) -> Void

protocol LikesService {
    func loadProfile(completion: @escaping ProfileCompletion)
    func saveLikes(_ likes: [String], completion: @escaping ProfileCompletion)
}

final class LikesServiceImpl: LikesService {

    private let networkClient: NetworkClient
    private let completionQueue = DispatchQueue(label: "catalog.likes", qos: .userInitiated)

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadProfile(completion: @escaping ProfileCompletion) {
        let request = GetProfileRequest()
        networkClient.send(request: request, type: UserProfile.self, completionQueue: completionQueue) { result in
            completion(result)
        }
    }

    func saveLikes(_ likes: [String], completion: @escaping ProfileCompletion) {
        loadProfile { [weak self] result in
            guard let self else {
                completion(.failure(NetworkClientError.urlSessionError))
                return
            }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let profile):
                let body = Self.profileBody(profile, likes: likes)
                let request = UpdateProfileRequest(httpBody: body)
                self.networkClient.send(request: request, type: UserProfile.self, completionQueue: self.completionQueue) { saveResult in
                    completion(saveResult)
                }
            }
        }
    }

    private static func profileBody(_ profile: UserProfile, likes: [String]) -> Data {
        var items: [(String, String)] = [
            ("name", profile.name),
            ("avatar", profile.avatar),
            ("description", profile.description),
            ("website", profile.website)
        ]
        if profile.nfts.isEmpty {
            items.append(("nfts", ""))
        } else {
            for id in profile.nfts {
                items.append(("nfts", id))
            }
        }
        if likes.isEmpty {
            items.append(("likes", ""))
        } else {
            for id in likes {
                items.append(("likes", id))
            }
        }
        return FormURLEncoder.encode(items)
    }
}
