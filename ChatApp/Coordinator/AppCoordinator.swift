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
        let viewController = ConversationsListVC()
        viewController.coordintor = self
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func showProfileVC() {
        let profileNC = UINavigationController()
        let profileCoordinator = ProfileCoordinator(navigationController: profileNC)
        profileCoordinator.start()
        
        navigationController.present(profileNC, animated: true)
    }
    
    func showChatVC(for conversation: ConversationCellModel?) {
        let conversationVC = ConversationVC()
        conversationVC.conversation = conversation
        navigationController.show(conversationVC, sender: nil)
    }
    
    func showSettings(delegate: ThemePresenterProtocol?) {
        let themeVC = ThemeVC()
        themeVC.themeDelegate = delegate
        navigationController.show(themeVC, sender: nil)
    }
}
