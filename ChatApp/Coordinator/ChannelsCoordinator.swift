//
//  ChannelsCoordinator.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 02.04.2023.
//

import UIKit
import TFSChatTransport

protocol ChannelsCoordinatorProtocol {
    func showConvesation(for channel: ChannelCellModel)
}

final class ChannelsCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = ChannelsListVC()
        viewController.coordinator = self
        viewController.tabBarItem = UITabBarItem(title: Project.Title.channels, image: Project.Image.chats, selectedImage: nil)
        navigationController.pushViewController(viewController, animated: false)
    }
}

extension ChannelsCoordinator: ChannelsCoordinatorProtocol {
    func showConvesation(for channel: ChannelCellModel) {
        let viewController = ConversationVC()
        viewController.channel = channel
        navigationController.pushViewController(viewController, animated: true)
    }
}
