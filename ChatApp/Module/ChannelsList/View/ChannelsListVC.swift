//
//  ChannelsVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 03.04.2023.
//

import UIKit
import Combine
import TFSChatTransport

enum Section: String, CaseIterable { case main }

final class ChannelsListVC: UITableViewController {
    // MARK: - Параметры
    
    private var viewModel       = ChannelsListViewModel()
    private var input           = PassthroughSubject<ChannelsListViewModel.Input, Never>()
    private var disposeBag      = Set<AnyCancellable>()
    
    public var coordinator: ChannelsCoordinator?
    private var dataSource: ChannelsDataSource?
    
    // MARK: - UI
    
    private var placheloder         = UIStackView()
    private var addChannelButton    = UIBarButtonItem()
    private var newChannelAlert     = UIAlertController(title: Project.Title.newChannel,
                                                        message: nil,
                                                        preferredStyle: .alert)
}

// MARK: - Жизненный цикл

extension ChannelsListVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        configure()
        configureNavigationBar()
        configureDataSource()
        configureRefreshController()
        configureSearchController()
        configureNewChannelAlert()
        
        input.send(.fetchChannels)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - Дополнительные методы

private extension ChannelsListVC {
    func bindViewModel() {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchChannelsDidFail(let error):
                    self?.showErrorAlert(title: Project.AlertTitle.ooops, message: error.rawValue)
                case .fetchChannelsDidSucceed(let channels), .channelsDidFilter(let channels):
                    self?.navigationItem.prompt = nil
//                    channels.forEach { model in
//                        self?.viewModel.save(with: model)
//                    }
                    self?.update(with: channels)
                case .showAddChannelAlert:
                    guard let self else { return }
                    self.present(self.newChannelAlert, animated: true)
                case .createChannelDidFail:
                    self?.showErrorAlert(title: Project.AlertTitle.ooops, message: Project.Title.Error.channelDidntCreate)
                case .createChannelDidSucceed:
                    break
                case .deleteChannelDidFail(let error):
                    self?.showErrorAlert(title: Project.AlertTitle.ooops, message: error.rawValue)
                case .deleteChannelDidSucceed:
                    self?.input.send(.fetchChannels)
                case .connectionIsBroken:
                    self?.showErrorAlert(title: Project.AlertTitle.noConnection, message: nil)
                }
            }.store(in: &disposeBag)
    }
    
    @objc
    func buttonTapped(_ button: UIControl) {
        switch button {
        case addChannelButton:
            input.send(.addChannelTapped)
        case self.refreshControl:
            input.send(.fetchChannels)
        default:
            break
        }
    }
    
    @objc
    func textFieldDidChange() {
        guard let text = newChannelAlert.textFields?.first?.text,
              !text.isEmpty
        else {
            newChannelAlert.actions.last?.isEnabled = false
            return
        }
        
        newChannelAlert.actions.last?.isEnabled = true
    }
    
    func update(with channels: [ChannelCellModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ChannelCellModel>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(channels, toSection: .main)
        
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot)
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - Методы конфигурации

private extension ChannelsListVC {
    func configure() {
        self.view.backgroundColor = .systemBackground
        
        self.tableView.register(ChannelTVCell.self, forCellReuseIdentifier: ChannelTVCell.id)
        self.tableView.rowHeight        = UITableView.automaticDimension
        self.tableView.tableFooterView  = UIView()
    }
    
    func configureNavigationBar() {
        // Строка навигации
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = Project.Title.channels
        navigationItem.backButtonTitle = " "
        
        // Кнопка добавления канала
        addChannelButton = UIBarButtonItem(title: Project.Button.addChannel, style: .plain, target: self, action: #selector(buttonTapped))
        navigationItem.setRightBarButton(addChannelButton, animated: true)
    }
    
    func configureDataSource() {
        typealias DataSource = ChannelsDataSource
        dataSource = DataSource(tableView: self.tableView,
                                cellProvider: { tableView, _, cellModel in
            let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTVCell.id) as? ChannelTVCell
            cell?.configure(with: cellModel)
            return cell
        })
        
        dataSource?.defaultRowAnimation = .fade
    }
    
    func configureRefreshController() {
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(buttonTapped), for: .valueChanged)
    }
    
    func configureSearchController() {
        let searchController = UISearchController()
        
        searchController.searchResultsUpdater   = self
        searchController.searchBar.placeholder  = Project.Title.Placeholder.searchChannels
        searchController.searchBar.delegate     = self
        
        self.navigationItem.searchController = searchController
    }
    
    func configureNewChannelAlert() {
        self.newChannelAlert.addTextField { textField in
            textField.placeholder = Project.Title.Placeholder.channelName
            textField.addTarget(self, action: #selector(self.textFieldDidChange), for: .allEditingEvents)
        }
        
        let cancel = UIAlertAction(title: Project.Button.cancel, style: .cancel)
        let create = UIAlertAction(title: Project.Button.create, style: .default) { [weak self] _ in
            guard let text = self?.newChannelAlert.textFields?.first?.text else { return }
            self?.input.send(.createChannel(name: text))
        }
        
        newChannelAlert.addAction(cancel)
        newChannelAlert.addAction(create)
    }
    
    func configureDeleteChannelAlert(for indexPath: IndexPath) {
        guard let channel = self.dataSource?.itemIdentifier(for: indexPath) else { return }
        
        let alert = UIAlertController(title: Project.AlertTitle.wait,
                                      message: Project.AlertTitle.deleteChannelQuestion(channel: channel),
                                      preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: Project.Button.cancel, style: .default)
        let delete = UIAlertAction(title: Project.Button.delete, style: .destructive) { _ in
            self.input.send(.delete(channel: channel))
        }
        
        alert.addAction(cancel)
        alert.addAction(delete)
        
        self.present(alert, animated: true)
    }
}

extension ChannelsListVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let channel = dataSource?.itemIdentifier(for: indexPath) else { return }
        coordinator?.showConvesation(for: channel)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, complete in
            self.configureDeleteChannelAlert(for: indexPath)
            complete(true)
        }
        
        deleteAction.title = Project.Button.delete
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension ChannelsListVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        input.send(.filterChannels(filter: searchController.searchBar.text))
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        input.send(.filterChannels(filter: nil))
    }
}
