//
//  ChatListVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.02.2023.
//

import UIKit

class ChatListVC: UIViewController {
    // MARK: Parameters
    public var coordintor: AppCoordinator?
    
    // MARK: - Views
    private var profileButton   = UIBarButtonItem()
    private var settingsButton  = UIBarButtonItem()
}

// MARK: - Lifecycle
extension ChatListVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        configureNavigationBar()
    }
}

// MARK: - Event methods
private extension ChatListVC {
    @objc
    func buttonTapped(_ button: UIBarButtonItem) {
        switch button {
        case profileButton:
            coordintor?.showProfileVC()
        default:
            break
        }
    }
}

// MARK: - Configure methods
private extension ChatListVC {
    func configure() {
        self.view.backgroundColor = .systemBackground
    }
    
    func configureNavigationBar() {
        // Navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Chat"
        
        // Profile BarButtonItem
        profileButton = UIBarButtonItem(image: Project.Image.profile,
                                        style: .plain,
                                        target: self,
                                        action: #selector(buttonTapped))
        navigationItem.setRightBarButton(profileButton, animated: true)
        
        // Settings BarButtonItem
        settingsButton = UIBarButtonItem(image: Project.Image.settings,
                                         style: .plain,
                                         target: self,
                                         action: #selector(buttonTapped))
        navigationItem.setLeftBarButton(settingsButton, animated: true)
    }
}
