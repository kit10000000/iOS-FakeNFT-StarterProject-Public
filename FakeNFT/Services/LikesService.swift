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
            guard let self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let profile):
                let dto = ProfileUpdateDto(
                    name: profile.name,
                    avatar: profile.avatar,
                    description: profile.description,
                    website: profile.website,
                    nfts: profile.nfts,
                    likes: likes
                )
                let request = UpdateProfileRequest(dto: dto)
                self.networkClient.send(request: request, type: UserProfile.self, completionQueue: self.completionQueue) { saveResult in
                    completion(saveResult)
                }
            }
        }
    }
}
