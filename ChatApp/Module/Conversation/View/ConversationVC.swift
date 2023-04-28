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
    
    public var channel: ChannelCellModel?
    private var user: User?
    
    private var input         = PassthroughSubject<ConversationViewModel.Input, Never>()
    private let viewModel     = ConversationViewModel()
    private var disposeBag    = Set<AnyCancellable>()
    
    private var dataSource: UICollectionViewDiffableDataSource<DateComponents, MessageCellModel>?
    private var layout: UICollectionViewCompositionalLayout?
    private var messageTextViewBottomAnchor = NSLayoutConstraint()
    
    // MARK: - UI
    
    private var placeholder         = TCPlaceholder()
    private var collectionView      = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private let chatNavigationBar   = TCChatNavigationBar()
    private let messageTextView     = TCMessageTextView()
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
        input.send(.fetchCachedMessages)
        input.send(.fetchMessages)
        input.send(.loadImage)
        input.send(.subscribeKeyboardEvents)
        input.send(.subscribeOnEvents)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
//        self.dataSource = nil
    }
}

// MARK: - Методы обработки событий

private extension ConversationVC {
    func bindViewModel() {
        viewModel.channel = channel
        let output = viewModel.transform(input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchMessagesSucceeded(let messages):
                    self?.update(with: messages)
                    self?.placeholder.isHidden = !messages.isEmpty
                case .imageLoadSucceeded(let image):
                    self?.chatNavigationBar.setImage(image)
                case .sendMessageSucceeded:
                    self?.messageTextView.resetText()
                case .keyboardDidShow(let height):
                    self?.messageTextViewBottomAnchor.constant = -height
                    UIView.animate(withDuration: 0.23) {
                        self?.view.layoutIfNeeded()
                    }
                    self?.scrollToBottom()
                case .keyboardDidHide:
                    self?.messageTextViewBottomAnchor.constant = 0
                    self?.scrollToBottom()
                case .errorOccured(let error):
                    self?.showErrorAlert(title: Project.AlertTitle.ooops, message: error.rawValue)
                }
            }.store(in: &disposeBag)
    }
    
    func update(with messages: [DateComponents: [MessageCellModel]]) {
        var snapshot = NSDiffableDataSourceSnapshot<DateComponents, MessageCellModel>()
        
        let sortedMessages = messages.sorted { first, second in
            return Calendar.current.date(from: first.key) ?? Date() < Calendar.current.date(from: second.key) ?? Date()
        }
        
        for (date, message) in sortedMessages {
            snapshot.appendSections([date])
            snapshot.appendItems(message, toSection: date)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard self?.view.window != nil else { return }
            self?.dataSource?.apply(snapshot, animatingDifferences: false)
            self?.scrollToBottom()
        }
    }
    
    @objc
    func sendButtonTapped() {
        let text = messageTextView.text
        guard !text.isEmpty else { return }
                
        input.send(.sendMessage(text: text))
    }
    
    @objc
    func addImageButtonTapped() {
        let imageLoaderVC = ListLoadImagesVC()
        let navigationController = UINavigationController(rootViewController: imageLoaderVC)
        imageLoaderVC.imagePickerSubject
            .sink { [weak self] (_, imageLink) in
                self?.messageTextView.addImage(imageLink)
            }.store(in: &disposeBag)
        self.present(navigationController, animated: true)
    }
    
    func scrollToBottom(animated: Bool = true) {
        guard
            let lastSection   = dataSource?.snapshot().sectionIdentifiers.last,
            let lastSectionIndex = dataSource?.snapshot().indexOfSection(lastSection),
            let numberOfItems = dataSource?.snapshot().numberOfItems(inSection: lastSection)
        else { return }
        
        let lastItemIndex = IndexPath(item: numberOfItems - 1, section: lastSectionIndex)
        
        collectionView.scrollToItem(at: lastItemIndex, at: .top, animated: animated)
    }
}

// MARK: - Методы конфигурации

private extension ConversationVC {
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
        messageTextView.imageButton.addTarget(nil, action: #selector(addImageButtonTapped), for: .touchUpInside)
        messageTextViewBottomAnchor = messageTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            messageTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageTextViewBottomAnchor,
            messageTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func configureCollectionView() {
        self.view.backgroundColor           = .systemBackground
        collectionView.backgroundColor      = .clear
        collectionView.keyboardDismissMode  = .interactive
        
        collectionView.register(MessageTextCVCell.self, forCellWithReuseIdentifier: MessageTextCVCell.id)
        collectionView.register(MessageImageCVCell.self, forCellWithReuseIdentifier: MessageImageCVCell.id)
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
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let isValidURL = URL(string: itemIdentifier.text)?.isValid

            switch isValidURL {
            case true:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageImageCVCell.id, for: indexPath) as? MessageImageCVCell
                cell?.configure(with: itemIdentifier)
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageTextCVCell.id, for: indexPath) as? MessageTextCVCell
                cell?.configure(with: itemIdentifier)
                return cell
            }
        })
        
        dataSource?.supplementaryViewProvider = { [unowned self] _, _, indexPath in
            if let cell = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                               withReuseIdentifier: DateCVHeader.id,
                                                                               for: indexPath) as? DateCVHeader {
                cell.configure(with: dataSource?.snapshot().sectionIdentifiers[indexPath.section])
                return cell
            }
            return nil

        }
    }
    
    func configureLayout() {
        layout = UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
            let itemSize    = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(180))
            let item        = NSCollectionLayoutItem(layoutSize: itemSize)
            let group       = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            
            group.contentInsets.leading     = 12
            group.contentInsets.trailing    = 12
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = .init(10)
            section.contentInsets.bottom = 10
            
            typealias SupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem
            let layoutSize      = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                         heightDimension: .estimated(25))
            let headerElement   = SupplementaryItem(layoutSize: layoutSize,
                                                    elementKind: UICollectionView.elementKindSectionHeader,
                                                    alignment: .topLeading)
            headerElement.pinToVisibleBounds = false
            section.boundarySupplementaryItems = [headerElement]
            
            return section
        })
        
        guard let layout else { return }
        self.collectionView.setCollectionViewLayout(layout, animated: true)
    }
}
