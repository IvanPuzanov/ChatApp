//
//  ThemePresenter.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 09.03.2023.
//

import UIKit

protocol ThemePresenterProtocol: AnyObject {
    func themeDidSet(_ theme: Theme)
}

final class ThemePresenter {
    private weak var view: ThemePresenterProtocol?
    private let persistenceService = PersistenceService()
}

extension ThemePresenter: AnyPresenter {
    typealias PresenterType = ThemePresenterProtocol
    func setDelegate(_ delegate: ThemePresenterProtocol) {
        self.view = delegate
    }
    
    func saveTheme() {
        switch UITraitCollection.current.userInterfaceStyle {
        case .dark:
            self.persistenceService.save(Theme.dark, forKey: .settings)
        case .light:
            self.persistenceService.save(Theme.light, forKey: .settings)
        default:
            break
        }
    }
}