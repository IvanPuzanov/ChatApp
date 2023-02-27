//
//  ProfileVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.02.2023.
//

import UIKit

final class ProfileVC: UIViewController {
    // MARK: - Views
    private var closeButton = UIBarButtonItem()
    private var editButton  = UIBarButtonItem()
}

// MARK: - Lifecycle
extension ProfileVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        configureNavigationBar()
    }
}

// MARK: - Configure methods
private extension ProfileVC {
    func configure() {
        self.view.backgroundColor = .systemBackground
    }
    
    func configureNavigationBar() {
        self.navigationItem.title = Project.Title.myProfile
        
        closeButton = UIBarButtonItem(title: Project.Button.close, style: .plain, target: nil, action: nil)
        navigationItem.setLeftBarButton(closeButton, animated: true)
        
        editButton = UIBarButtonItem(title: Project.Button.edit, style: .plain, target: nil, action: nil)
        navigationItem.setRightBarButton(editButton, animated: true)
    }
}
