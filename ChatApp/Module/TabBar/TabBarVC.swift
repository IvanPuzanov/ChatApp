//
//  TabBarVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 02.04.2023.
//

import UIKit

final class TabBarVC: UITabBarController {
    // MARK: - Координаторы
    
    private let channelsCoordinator: Coordinator = ChannelsCoordinator(UINavigationController())
    private let settingsCoordinator: Coordinator = SettingsCoordinator(UINavigationController())
    private let profileCoordinator: Coordinator  = ProfileCoordinator(UINavigationController())
}

// MARK: - Жизненный цикл

extension TabBarVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startCoordinators()
        configure()
    }
}

// MARK: - Методы конфигурации

private extension TabBarVC {
    func configure() {
        viewControllers = [
            channelsCoordinator.navigationController,
            settingsCoordinator.navigationController,
            profileCoordinator.navigationController
        ]
    }
    
    func startCoordinators() {
        channelsCoordinator.start()
        settingsCoordinator.start()
        profileCoordinator.start()
    }
}
