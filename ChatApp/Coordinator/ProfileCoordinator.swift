//
//  ProfileCoordinator.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import UIKit

final class ProfileCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = ProfileVC()
        viewController.tabBarItem = UITabBarItem(title: Project.Title.profile, image: Project.Image.profile, selectedImage: nil)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showUserEditor(for user: User) {
        let viewController  = ProfileEditorVC()
        viewController.user = user
        
        navigationController.present(UINavigationController(rootViewController: viewController), animated: true)
    }
}
