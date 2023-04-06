//
//  SettingsCoordinator.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 02.04.2023.
//

import UIKit

final class SettingsCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = ThemeVC()
        viewController.tabBarItem = UITabBarItem(title: Project.Title.settings, image: Project.Image.settings, selectedImage: nil)
        navigationController.pushViewController(viewController, animated: false)
    }
}
