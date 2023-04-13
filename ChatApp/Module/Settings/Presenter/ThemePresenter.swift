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
    private let persistenceService = UserDefaultsService()
}

extension ThemePresenter: AnyPresenter {
    typealias PresenterType = ThemePresenterProtocol
    func setDelegate(_ delegate: ThemePresenterProtocol) {
        self.view = delegate
    }
    
    func saveTheme() {
        switch UITraitCollection.current.userInterfaceStyle {
        case .dark:
            self.persistenceService.save(Theme.dark, forKey: .themeSettings)
        case .light:
            self.persistenceService.save(Theme.light, forKey: .themeSettings)
        default:
            break
        }
    }
}
