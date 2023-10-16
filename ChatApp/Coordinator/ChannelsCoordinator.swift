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
    // MARK: - Параметры
    
    var navigationController: UINavigationController
    private lazy var channelsListModuleAssembly: ChannelsListModuleAssembly = {
        ChannelsListModuleAssembly()
    }()
    
    // MARK: - Инициализация
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Методы
    
    func start() {
        let viewController = channelsListModuleAssembly.makeChannelsListModule(output: self)
        viewController.tabBarItem = UITabBarItem(title: Project.Title.channels, image: Project.Image.chats, selectedImage: nil)
        navigationController.pushViewController(viewController, animated: false)
    }
}

// MARK: - ChannelsModuleOutput

extension ChannelsCoordinator: ChannelsListOutput {
    func showConversation(for channel: ChannelCellModel) {
        let viewController = ConversationVC()
        viewController.channel = channel
        navigationController.pushViewController(viewController, animated: true)
    }
}
