//
//  ChatListVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.02.2023.
//

import UIKit

enum Section: String, CaseIterable {
    case online = "Online"
    case history = "History"
}

class ChatListVC: UITableViewController {
    // MARK: - Parameters
    public var coordintor: AppCoordinator?
    private let presenter = ChatListPresenter()
    private var dataSource: UITableViewDiffableDataSource<Section, ConversationCellModel>!
    
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
        configureDataSource()
        
        presenter.fetchUserProfile()
        presenter.fetchConversations()
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
    
    func update(with conversations: [ConversationCellModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ConversationCellModel>()
        
        snapshot.appendSections([.online, .history])
        let online  = conversations.filter { $0.isOnline }
        let history = conversations.filter { !$0.isOnline }
        
        snapshot.appendItems(online, toSection: .online)
        snapshot.appendItems(history, toSection: .history)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}

// MARK: - Configure methods
private extension ChatListVC {
    func bindToPresenter() {
        self.presenter.setDelegate(self)
        self.presenter.fetchConversations()
    }
    
    func configure() {
        self.view.backgroundColor = .systemBackground
        
        self.tableView.register(ConversationTVCell.self, forCellReuseIdentifier: ConversationTVCell.id)
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    func configureNavigationBar() {
        // Navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = Project.Title.chat
        navigationItem.backButtonTitle = " "
        
        // Profile BarButtonItem
        profileButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        let profileNavButton = UIBarButtonItem(customView: profileButton)
        navigationItem.setRightBarButton(profileNavButton, animated: true)
        
        // Settings BarButtonItem
        settingsButton = UIBarButtonItem(image: Project.Image.settings,
                                         style: .plain,
                                         target: self,
                                         action: #selector(buttonTapped))
        navigationItem.setLeftBarButton(settingsButton, animated: true)
    }
    
    func configureDataSource() {
        typealias DataSource = UITableViewDiffableDataSource<Section, ConversationCellModel>
        dataSource = DataSource(tableView: self.tableView, cellProvider: { tableView, indexPath, cellModel in
            let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTVCell.id) as? ConversationTVCell
            cell?.configure(with: cellModel)
            return cell
        })
        
        dataSource.defaultRowAnimation = .fade
    }
}

// MARK: - ChatListPresenterProtocol
extension ChatListVC: ChatListPresenterProtocol {
    func didFetchConversations(_ conversations: [ConversationCellModel]) {
        update(with: conversations)
    }
    
    func userProfileDidFetch(_ userProfile: UserProfile) {
        profileButton.setName(userProfile.name)
        profileButton.setImage(userProfile.avatar)
    }
}

// MARK: - UITableViewDelegate
extension ChatListVC {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ConversationTVHeader()
        header.configure(with: Section.allCases[section])
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource.itemIdentifier(for: indexPath)
        coordintor?.showChatVC(for: model)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
