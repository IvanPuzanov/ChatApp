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
    var appCoordinator: AppCoordinator?
}

// MARK: - App Жизненный цикл
extension AppDelegate: UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Создаю navigationController, который будет использоваться
        // координатором
        let navigationController = UINavigationController()
        
        // Создаю координатор приложения
        appCoordinator = AppCoordinator(navigationController: navigationController)
        
        // Настраиваю окно приложения
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        // Запускается работа координатора
        appCoordinator?.start()
        
        // Установка темы приложения
        setupAppearance()
        
        return true
    }
    
    func setupAppearance() {
        let persistenceService = PersistenceService()
        guard let theme = persistenceService.fetchTheme() else { return }
        
        switch theme {
        case .dark:
            self.window?.overrideUserInterfaceStyle = .dark
        case .light:
            self.window?.overrideUserInterfaceStyle = .light
        }
    }
}
