//
//  FileServiceTests.swift
//  ChatAppUnitTests
//
//  Created by Ivan Puzanov on 10.05.2023.
//

import XCTest
@testable import ChatApp

final class FileServiceTests: XCTestCase {
    
    // MARK: - Параметры
    
    private var fileService = FileService.shared
    private var actualUser: User = .defaultUser
    
    // MARK: - Методы тестирования

    func testFetchUser() {
        // Act
        fileService.fetchUser()
        
        // Assert
        XCTAssertEqual(5, 5)
    }
    
    func testSaveNewUser() {
        // Arrange
        let currentUser = fileService.currentUser
        let newUser     = User(name: UUID().uuidString, bio: UUID().uuidString, avatar: nil)
        
        // Act
        do {
            try fileService.save(user: newUser)
        } catch {}
        
        // Assert
        XCTAssertNotEqual(currentUser, newUser)
    }
    
    func testSaveSameUser() {
        // Arrange
        let currentUser = fileService.currentUser
        let newUser     = currentUser
        
        // Act
        do {
            try fileService.save(user: newUser)
        } catch {
            XCTAssertTrue(false)
        }
        
        // Assert
        XCTAssertEqual(currentUser, newUser)
    }
}
