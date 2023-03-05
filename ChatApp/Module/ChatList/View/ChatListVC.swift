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
    private let presenter = ChatListPresenter()
    
    // MARK: - Views
    private var profileButton   = TCProfileImageView(size: .small)
    private var settingsButton  = UIBarButtonItem()
}

// MARK: - Lifecycle
extension ChatListVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindToPresenter()
        configure()
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        coordintor?.showProfileVC()
    }
}

// MARK: - Event methods
private extension ChatListVC {
    @objc
    func buttonTapped(_ button: UIView) {
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
    func bindToPresenter() {
        self.presenter.setDelegate(self)
    }
    
    func configure() {
        self.view.backgroundColor = .systemBackground
    }
    
    func configureNavigationBar() {
        // Navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Chat"
        
        // Profile BarButtonItem
        profileButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        profileButton.setName("Ivan Puzanov")
        let profileNavButton = UIBarButtonItem(customView: profileButton)
        navigationItem.setRightBarButton(profileNavButton, animated: true)
        
        // Settings BarButtonItem
        settingsButton = UIBarButtonItem(image: Project.Image.settings,
                                         style: .plain,
                                         target: self,
                                         action: #selector(buttonTapped))
        navigationItem.setLeftBarButton(settingsButton, animated: true)
    }
}

// MARK: - Conforming ChatListPresenterProtocol
extension ChatListVC: ChatListPresenterProtocol {
    
}
