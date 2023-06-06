//
//  ProfileAssembly.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 22.05.2023.
//

import UIKit

final class ProfileAssembly {
    
    func makeProfileModule(moduleOutput: ProfileCoordinator) -> UIViewController {
        let fileService = FileService.shared
        let viewModel   = ProfileViewModel(fileService: fileService)
        let profileVC   = ProfileVC(viewModel: viewModel)
        
        return profileVC
    }
}
