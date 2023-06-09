//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.02.2023.
//

import UIKit

@main
class AppDelegate: UIResponder {
    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
}

// MARK: - Жизненный цикл

extension AppDelegate: UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Настраиваю окно приложения
        window?.rootViewController = TabBarVC()
        window?.makeKeyAndVisible()
        
        // Установка темы приложения
        setupAppearance()
        
        return true
    }
    
    func setupAppearance() {
        let persistenceService = UserDefaultsService()
        guard let theme = persistenceService.fetchTheme() else { return }
        
        switch theme {
        case .dark:
            self.window?.overrideUserInterfaceStyle = .dark
        case .light:
            self.window?.overrideUserInterfaceStyle = .light
        }
    }
}
