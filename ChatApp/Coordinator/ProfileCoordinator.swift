//
//  ProfileCoordinator.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import UIKit

protocol ProfileCoordinatorProtocol {
    func showUserEditor(for user: User)
    func showImageLoader()
}

final class ProfileCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    // MARK: - Инициализация
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Запуск координатора
    
    func start() {
        let viewController = ProfileVC()
        viewController.tabBarItem = UITabBarItem(title: Project.Title.profile, image: Project.Image.profile, selectedImage: nil)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension ProfileCoordinator: ProfileCoordinatorProtocol {
    func showUserEditor(for user: User) {
        let viewController  = ProfileEditorVC()
        viewController.user = user
        
        navigationController.present(UINavigationController(rootViewController: viewController), animated: true)
    }
    
    func showImageLoader() {
        let viewController = ListLoadImagesVC()
        navigationController.present(UINavigationController(rootViewController: viewController), animated: true)
    }
}
