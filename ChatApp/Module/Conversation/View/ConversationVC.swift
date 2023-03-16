//
//  ConversationVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.03.2023.
//

import UIKit

enum DateSection: Int, Hashable {
    case early = 0
    case today = 1
}

final class ConversationVC: UIViewController {
    // MARK: - Параметры
    public var conversation: ConversationCellModel?
    private let presenter = ConversationPresenter()
    private var messageTextViewBottomAnchor: NSLayoutConstraint?
    
    private var dataSource: UICollectionViewDiffableDataSource<DateComponents, MessageCellModel>!
    private var layout: UICollectionViewCompositionalLayout!
    
    // MARK: - UI
    private var collectionView      = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private let chatNavigationBar   = TCChatNavigationBar()
    private let messageTextView     = TCMessageTextView()
    private let tableView           = UITableView()
}

// MARK: - Жизненный цикл
extension ConversationVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindToPresenter()
//        configure()
        configureMessageTextView()
        configureCollectionView()
        configureNavigationBar()
        configureDataSource()
        configureLayout()
    }
}

// MARK: -
private extension ConversationVC {
    func update(with messages: [DateComponents: [MessageCellModel]]) {
        var snapshot = NSDiffableDataSourceSnapshot<DateComponents, MessageCellModel>()
        
        for (key, value) in messages {
            if !snapshot.sectionIdentifiers.contains(key) {
                snapshot.appendSections([key])
            }
            
            snapshot.appendItems(value, toSection: key)
        }
//
//        snapshot.appendSections([.early, .today])
//
//        if let earlyMessages = messages[.early] {
//            snapshot.appendItems(earlyMessages, toSection: .early)
//        }
//        if let todayMessages = messages[.today] {
//            snapshot.appendItems(todayMessages, toSection: .today)
//        }
//
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot)
        }
    }
    
    func update(with messages: [MessageSnapshotModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<DateComponents, MessageCellModel>()
        
        messages.forEach { model in
            if !snapshot.sectionIdentifiers.contains(model.date) {
                snapshot.appendSections([model.date])
            }
            
            snapshot.appendItems(model.messages, toSection: model.date)
        }
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot)
        }
    }
}

// MARK: - Методы конфигурации
private extension ConversationVC {
    func bindToPresenter() {
        self.presenter.setDelegate(self)
        self.presenter.fetchMessages(for: conversation)
        self.presenter.addObservers()
    }
    
    func configureMessageTextView() {
        self.view.addSubview(messageTextView)
        
        messageTextViewBottomAnchor = messageTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            messageTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageTextViewBottomAnchor!,
            messageTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
        ])
    }
    
    func configureCollectionView() {
        self.view.backgroundColor = .systemBackground
        self.collectionView.backgroundColor = .systemBackground
        self.collectionView.keyboardDismissMode = .interactive
        
        self.collectionView.register(MessageCVCell.self, forCellWithReuseIdentifier: MessageCVCell.id)
        self.collectionView.register(DateCVHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DateCVHeader.id)
        
        self.view.addSubview(collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: messageTextView.topAnchor, constant: -3)
        ])
    }
    
    func configureNavigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        
        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        navigationItem.compactAppearance = navigationBarAppearance
        
        // Configure chat navigation bar
        self.view.addSubview(chatNavigationBar)
        
        chatNavigationBar.setName(conversation?.name)
        chatNavigationBar.setImage(conversation?.image)
        
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
        layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ in
            let itemSize    = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(70))
            let item        = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let group       = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            group.contentInsets.leading = 12
            group.contentInsets.trailing = 12
            let section     = NSCollectionLayoutSection(group: group)
            
            typealias SupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem
            let layoutSize      = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(25))
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

// MARK: - ChatPresenterProtocol
extension ConversationVC: ConversationPresenterProtocol {
    func messagesDidFetch(_ messages: [DateComponents: [MessageCellModel]]) {
        update(with: messages)
    }
    
    func messagesDidFetch(_ messages: [DateSection : [MessageCellModel]]) {
//        update(with: messages)
    }
    
    func messagesDidFetch(_ messages: [MessageSnapshotModel]) {
//        update(with: messages)
    }
    
    func keyboardWillShow(height: CGFloat) {
        messageTextViewBottomAnchor?.constant = -height
        view.layoutSubviews()
        
        
    }
    
    func keyboardDidHide() {
        messageTextViewBottomAnchor?.constant = -10
        view.layoutSubviews()
    }
}
