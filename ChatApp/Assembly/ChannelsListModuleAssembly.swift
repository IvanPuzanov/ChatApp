//
//  ChannelsListModuleAssembly.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 10.10.2023.
//

import UIKit

final class ChannelsListModuleAssembly {
    // MARK: - Параметры
    
    private lazy var serviceAssembly: ServiceAssembly = {
        ServiceAssembly()
    }()
    
    // MARK: - Методы
    
    func makeChannelsListModule(output: ChannelsListOutput) -> UIViewController {
        let viewModel = ChannelsListViewModel(sseService: serviceAssembly.makeSSEService(),
                                              chatService: serviceAssembly.makeChatService(),
                                              coreDataService: serviceAssembly.makeCoreDataService(),
                                              moduleOutput: output)
        let viewController = ChannelsListVC(viewModel: viewModel)
        
        return viewController
    }
}
