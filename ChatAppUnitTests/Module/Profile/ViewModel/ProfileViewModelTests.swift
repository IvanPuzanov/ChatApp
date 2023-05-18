//
//  ProfileViewModelTests.swift
//  ChatAppUnitTests
//
//  Created by Ivan Puzanov on 11.05.2023.
//

import XCTest
@testable import ChatApp
import Combine

final class ProfileViewModelTests: XCTestCase {
    
    // MARK: - Методы тестирования
    
    func testTransform() {
        let viewModel   = ProfileViewModel(fileService: FileService.shared)
        let input       = PassthroughSubject<ProfileViewModel.Input, Never>()
        var disposeBag  = Set<AnyCancellable>()
        
        viewModel
            .transform(input.eraseToAnyPublisher())
            .sink { event in
                switch event {
                case .userDidFetch:
                    XCTAssertTrue(true)
                case .showEditor:
                    XCTAssertTrue(true)
                }
            }.store(in: &disposeBag)
        
        input.send(.fetchUser)
        input.send(.showEditor)
    }
    
}
