//
//  AppService.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 14.03.2023.
//

import UIKit

final class AppService {
    // MARK: - Singletone
    static var shared = AppService()
    private init() {}
    
    // MARK: - Параметры
    var appearance: Theme = .light
}

private extension AppService {
    func validateAppearance() {
        
    }
}

