//
//  ListLoadImagesViewModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 25.04.2023.
//

import UIKit
import Combine

final class ListLoadImagesViewModel {
    
    // MARK: - Сервисы
    
    private var imagesService = ImagesService(networkService: .init(), requestFactory: URLRequestFactory(host: "api.unsplash.com"))
    
    // MARK: - Combine
    
    private var output      = PassthroughSubject<Output, Never>()
    private var disposeBag  = Set<AnyCancellable>()
    
    // MARK: - Параметры
    
    private var page: Int               = 1
    private var images: [ImageModel]    = []
}

extension ListLoadImagesViewModel: ViewModel {
    enum Input {
        case fetchImagesList
        case fetchMoreImages
    }
    
    enum Output {
        case errorOccured
        case imagesListFetchingSucceeded(images: [ImageModel]?)
    }
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .fetchImagesList:
                self?.fetchImages()
            case .fetchMoreImages:
                self?.page += 1
                self?.fetchImages()
            }
        }.store(in: &disposeBag)
        
        return output.eraseToAnyPublisher()
    }
}

private extension ListLoadImagesViewModel {
    func fetchImages() {
        imagesService.getImages(for: page) { [weak self] result in
            switch result {
            case .success(let images):
                var newImages = Set(images).subtracting(self?.images ?? [])
                self?.images += newImages
                self?.output.send(.imagesListFetchingSucceeded(images: self?.images))
            case .failure:
                break
            }
        }
    }
}
