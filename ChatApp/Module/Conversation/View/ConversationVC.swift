//
//  ConversationVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.03.2023.
//

import UIKit
import Combine
import TFSChatTransport

final class ConversationVC: UIViewController {
    // MARK: - Параметры
    
    public var channel: ChannelViewModel?
    private var user: User?
    
    private let viewModel       = ConversationViewModel()
    private var input           = PassthroughSubject<ConversationViewModel.Input, Never>()
    private var cancellables    = Set<AnyCancellable>()
    
    private var dataSource: UICollectionViewDiffableDataSource<DateComponents, MessageCellModel>!
    private var layout: UICollectionViewCompositionalLayout!
    private var messageTextViewBottomAnchor = NSLayoutConstraint()
    
    // MARK: - UI
    
    private var placeholder         = TCPlaceholder()
    private var collectionView      = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private let chatNavigationBar   = TCChatNavigationBar()
    private let messageTextView     = TCMessageTextView()
    private let tableView           = UITableView()
}

// MARK: - Жизненный цикл

extension ConversationVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        configurePlaceholder()
        configureMessageTextView()
        configureCollectionView()
        configureNavigationBar()
        configureDataSource()
        configureLayout()
        
        input.send(.fetchUser)
        
        guard let channel else { return }
        input.send(.fetchMessages(for: channel))
        input.send(.loadImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
}

// MARK: - Методы обработки событий

private extension ConversationVC {
    func update(with messages: [DateComponents: [MessageCellModel]]) {
        var snapshot = NSDiffableDataSourceSnapshot<DateComponents, MessageCellModel>()
        
        for (date, message) in messages {
            snapshot.appendSections([date])
            snapshot.appendItems(message, toSection: date)
        }
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    @objc
    func sendButtonTapped() {
        let text = messageTextView.text
        guard !text.isEmpty else { return }
                
        input.send(.sendMessage(text: text))
    }
}

// MARK: - Методы конфигурации

private extension ConversationVC {
    func bindViewModel() {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchMessagesDidFail(let error):
                    self?.showErrorAlert(title: Project.AlertTitle.ooops, message: error.rawValue)
                case .fetchMessagesSucceed(let messages):
                    self?.update(with: messages)
                    self?.placeholder.isHidden = !messages.isEmpty
                case .imageLoadSucceed(let image):
                    self?.chatNavigationBar.setImage(image)
                case .sendMessageDidFail(let error):
                    self?.showErrorAlert(title: Project.AlertTitle.ooops, message: error.rawValue)
                case .sendMessageSucceed:
                    self?.messageTextView.resetText()
                case .keyboardDidShow(let height):
                    self?.messageTextViewBottomAnchor.constant = -height
                case .keyboardDidHide:
                    self?.messageTextViewBottomAnchor.constant = 0
                }
            }.store(in: &cancellables)
    }
    
    func configurePlaceholder() {
        view.addSubview(placeholder)
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        
        placeholder.set(image: Project.Image.trayFill, message: Project.Title.Error.noMessagesInChat)
        
        NSLayoutConstraint.activate([
            self.placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func configureMessageTextView() {
        self.view.addSubview(messageTextView)
        
        messageTextView.sendButton.addTarget(nil, action: #selector(sendButtonTapped), for: .touchUpInside)
        messageTextViewBottomAnchor = messageTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            messageTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageTextViewBottomAnchor,
            messageTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func configureCollectionView() {
        self.view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .none
        
        collectionView.register(MessageCVCell.self, forCellWithReuseIdentifier: MessageCVCell.id)
        collectionView.register(DateCVHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: DateCVHeader.id)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: messageTextView.topAnchor)
        ])
    }
    
    func configureNavigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()

        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        navigationItem.compactAppearance = navigationBarAppearance
        
        self.view.addSubview(chatNavigationBar)
        
        chatNavigationBar.setName(channel?.name)
        
        NSLayoutConstraint.activate([
            chatNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatNavigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            chatNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func configureDataSource() {
        typealias DataSource = UICollectionViewDiffableDataSource<DateComponents, MessageCellModel>
        dataSource = DataSource(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageCVCell.id, for: indexPath) as? MessageCVCell
            cell?.configure(with: itemIdentifier)
            return cell
        })
        
        dataSource.supplementaryViewProvider = { [unowned self] _, _, indexPath in
            if let cell = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                               withReuseIdentifier: DateCVHeader.id,
                                                                               for: indexPath) as? DateCVHeader {
                cell.configure(with: dataSource.snapshot().sectionIdentifiers[indexPath.section])
                return cell
            }
            return nil

        }
    }
    
    func configureLayout() {
        layout = UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
            let itemSize    = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(70))
            let item        = NSCollectionLayoutItem(layoutSize: itemSize)
            let group       = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            
            group.contentInsets.leading     = 12
            group.contentInsets.trailing    = 12
            
            let section = NSCollectionLayoutSection(group: group)
            
            typealias SupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem
            let layoutSize      = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                         heightDimension: .estimated(25))
            let headerElement   = SupplementaryItem(layoutSize: layoutSize,
                                                    elementKind: UICollectionView.elementKindSectionHeader,
                                                    alignment: .topLeading)
            headerElement.pinToVisibleBounds = true
            section.boundarySupplementaryItems = [headerElement]
            
            return section
        })
        
        self.collectionView.setCollectionViewLayout(layout, animated: true)
    }
}
