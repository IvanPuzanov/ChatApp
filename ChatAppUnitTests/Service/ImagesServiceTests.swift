//
//  ImagesServiceTests.swift
//  ChatAppUnitTests
//
//  Created by Ivan Puzanov on 10.05.2023.
//

import XCTest
@testable import ChatApp

final class ImagesServiceTests: XCTestCase {
    
    func testGetImages() {
        // Arrange
        let networkService  = NetworkService()
        let urlRequest      = URLRequestFactory(host: "api.unsplash.com")
        let imagesService   = ImagesService(networkService: networkService, requestFactory: urlRequest)
        
        // Act
        imagesService.getImages(for: 1) { result in
            switch result {
            case .success:
                // Assert
                XCTAssertTrue(true)
            case .failure:
                // Assert
                XCTAssertTrue(false)
            }
        }
    }
    
}
