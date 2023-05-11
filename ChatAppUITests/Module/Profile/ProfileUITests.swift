//
//  ProfileUITests.swift
//  ChatAppUITests
//
//  Created by Ivan Puzanov on 10.05.2023.
//

import XCTest
@testable import ChatApp

final class ProfileUITests: XCTestCase {
    
    // MARK: - Методы тестирования

    func testProfileUIElementsExisting() {
        // Arrange
        let app = XCUIApplication()
        
        // Act
        app.launch()
        
        // Переход на экран ProfileVC
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        
        // Проверка наличия нужных UI компонентов
        let profileImageExists  = app.otherElements["profileImageView"].exists
        let nameLabelExists     = app.staticTexts["nameLabel"].exists
        let bioLabelExists      = app.staticTexts["bioLabel"].exists
        
        // Assert
        XCTAssertTrue(profileImageExists)
        XCTAssertTrue(nameLabelExists)
        XCTAssertTrue(bioLabelExists)
    }
}
