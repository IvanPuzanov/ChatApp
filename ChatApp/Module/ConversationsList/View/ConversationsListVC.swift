//
//  ConversationsListVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.02.2023.
//

import UIKit
import Combine

enum Section: String, CaseIterable {
    case online = "Online"
    case history = "History"
}

class ConversationsListVC: UITableViewController {
    // MARK: - Параметры
    public var coordintor: AppCoordinator?
    private let presenter = ConversationsListPresenter()
    private var dataSource: UITableViewDiffableDataSource<Section, ConversationCellModel>!
    
    // MARK: - UI
    private var profileButton   = TCProfileImageView(size: .small)
    private var settingsButton  = UIBarButtonItem()
    
    let fileService = FileService.shared
    var sub: Cancellable?
    var userProfile: User = .defaultUser {
        didSet {
            self.profileButton.setUser(user: userProfile)
        }
    }
}

// MARK: - Жизненный цикл
extension ConversationsListVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindToPresenter()
        
        configure()
        configureNavigationBar()
        configureDataSource()
        
        presenter.createSubscriptions()
        presenter.fetchConversations()
        presenter.fetchUser()
    }
}

// MARK: - Методы событий
private extension ConversationsListVC {
    @objc
    func buttonTapped(_ button: UIView) {
        switch button {
        case profileButton:
            self.coordintor?.showProfileVC()
        case settingsButton:
            self.coordintor?.showSettings()
        default:
            break
        }
    }
    
    func update(with snapshot: NSDiffableDataSourceSnapshot<Section, ConversationCellModel>) {
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}

// MARK: - Методы конфигурации
private extension ConversationsListVC {
    func bindToPresenter() {
        self.presenter.setDelegate(self)
        self.presenter.fetchConversations()
    }
    
    func configure() {
        self.view.backgroundColor = .systemBackground
        
        self.tableView.register(ConversationTVCell.self, forCellReuseIdentifier: ConversationTVCell.id)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()
    }
    
    func configureNavigationBar() {
        // Строка навигации
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = Project.Title.chat
        navigationItem.backButtonTitle = " "
        
        // Кнопка профиля
        profileButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        let profileNavButton = UIBarButtonItem(customView: profileButton)
        navigationItem.setRightBarButton(profileNavButton, animated: true)
        
        // Кнопка настроек
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
extension ConversationsListVC: ConversationsListPresenterProtocol {
    func didFetchConversations(_ snapshot: NSDiffableDataSourceSnapshot<Section, ConversationCellModel>) {
        update(with: snapshot)
    }
    
    func userProfileDidFetch(_ user: User) {
        profileButton.setUser(user: user)
    }
}

// MARK: - UITableViewDelegate
extension ConversationsListVC {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ConversationTVHeader()
        header.configure(with: Section.allCases[section])
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource.itemIdentifier(for: indexPath)
        coordintor?.showChatVC(for: model)
    }
}

