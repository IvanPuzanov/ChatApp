//
//  ImagesService.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 28.04.2023.
//

import Foundation

protocol ImagesServiceProtocol {
    func getImages(for page: Int, completion: @escaping (Result<[ImageModel], Error>) -> Void)
}

final class ImagesService {
    private let networkService: NetworkService
    private let requestFactory: URLRequestFactoryProtocol
    
    init(networkService: NetworkService, requestFactory: URLRequestFactoryProtocol) {
        self.networkService = networkService
        self.requestFactory = requestFactory
    }
}

extension ImagesService: ImagesServiceProtocol {
    func getImages(for page: Int, completion: @escaping (Result<[ImageModel], Error>) -> Void) {
        do {
            let imagesRequest = try requestFactory.getImagesRequest(for: page)
            networkService.sendRequest(imagesRequest, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
}
