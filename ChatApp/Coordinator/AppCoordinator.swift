//
//  AppCoordinator.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.02.2023.
//

import UIKit

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = MainVC()
        viewController.coordintor = self
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func showDetailedVC() {
        let viewController = DetailVC()
        navigationController.show(viewController, sender: nil)
    }
}
