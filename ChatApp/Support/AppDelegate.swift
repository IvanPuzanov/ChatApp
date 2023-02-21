//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.02.2023.
//

import UIKit

@main
class AppDelegate: UIResponder {
    var window: UIWindow?
    var appState: ApplicationState = .notRunning
    var appCoordinator: AppCoordinator?
    let showLogs = Bundle.main.object(forInfoDictionaryKey: SystemLog.showLogs) as? Bool
}

// MARK: - App Lifecycle
extension AppDelegate: UIApplicationDelegate {
    // MARK: - ПРИМЕЧАНИЕ
    // Данный метод сообщает делегату, что процесс запуска начался
    // Я ПРЕДПОЛАГАЮ, что в этот момент приложение переходит ИЗ состояния
    // Not running
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
        if let showLogs, showLogs {
            appStateChanged(application, from: .notRunning, to: ApplicationState(rawValue: application.applicationState.rawValue), in: #function)
        }
        
        return true
    }
    
    // Данный метод сообщает делегату, что загрузка приложения закончена
    // и приложение почти готово к запуску
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Создаю navigationController, который будет использоваться
        // координатором
        let navigationController = UINavigationController()
        
        // Создаю координатор приложения
        appCoordinator = AppCoordinator(navigationController: navigationController)
        
        // Создаю окно приложения
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        // Запускается работа координатора
        appCoordinator?.start()
        
        // Записывается состояние приложения в переменную
        if let appState = ApplicationState(rawValue: application.applicationState.rawValue) {
            self.appState = appState
        }
        
        return true
    }
    
    // Данный метод вызывается ПОСЛЕ того, как
    // приложение переходит в состояние ACTIVE
    func applicationDidBecomeActive(_ application: UIApplication) {
        appStateChanged(application, from: appState, to: ApplicationState(rawValue: application.applicationState.rawValue), in: #function)
    }
    
    // MARK: ПРИМЕЧАНИЕ
    // Данный метод вызывается непосредственно ПЕРЕД тем
    // как приложение выйдет ИЗ состояния ACTIVE, при этом
    // параметр 'application.applicationState' всё еще хранит состояние ACTIVE
    // поэтому я ЯВНО указываю переход в INACTIVE
    func applicationWillResignActive(_ application: UIApplication) {
        appStateChanged(application, from: appState, to: .inactive, in: #function)
    }
    
    // Данный метод вызывается ПОСЛЕ того, как
    // приложение переходит в состояние BACKGROUND
    func applicationDidEnterBackground(_ application: UIApplication) {
        appStateChanged(application, from: appState, to: ApplicationState(rawValue: application.applicationState.rawValue), in: #function)
    }
    
    // Данный метод вызывается ПЕРЕД тем, как
    // приложение перейдёт в FOREGROUND
    func applicationWillEnterForeground(_ application: UIApplication) {
        appStateChanged(application, from: ApplicationState(rawValue: application.applicationState.rawValue), to: .inactive, in: #function)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        appStateChanged(application, from: ApplicationState(rawValue: application.applicationState.rawValue), to: .notRunning, in: #function)
    }
}

extension AppDelegate {
    func appStateChanged(_ application: UIApplication,
                         from previousState: ApplicationState?,
                         to nextState: ApplicationState?,
                         in method: String) {
        guard let showLogs, showLogs else { return }
        guard let previousState, let nextState else { return }
        print("Application moved from \(previousState.description) to \(nextState.description): \(method)")
        
        appState = nextState
    }
}
