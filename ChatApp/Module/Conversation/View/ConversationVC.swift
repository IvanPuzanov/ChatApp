//
//  ConversationVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.03.2023.
//

import UIKit

enum DateSection: Hashable {
    case early
    case today
}

final class ConversationVC: UICollectionViewController {
    // MARK: - Parameters
    public var conversation: ConversationCellModel?
    private let presenter = ConversationPresenter()
    private var messageTextViewBottomAnchor: NSLayoutConstraint?
    
    private var dataSource: UICollectionViewDiffableDataSource<DateSection, MessageCellModel>!
    private var layout: UICollectionViewCompositionalLayout!
    
    // MARK: - Views
    private let chatNavigationBar   = TCChatNavigationBar()
    private let messageTextView     = TCMessageTextView()
    private let tableView           = UITableView()
}

// MARK: - Lifecycle
extension ConversationVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindToPresenter()
        configure()
        configureMessageTextView()
        configureNavigationBar()
        configureDataSource()
        configureLayout()
    }
}

// MARK: -
private extension ConversationVC {
    func update(with messages: [MessageCellModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<DateSection, MessageCellModel>()
        
        snapshot.appendSections([.today])
        snapshot.appendItems(messages, toSection: .today)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot)
        }
    }
}

// MARK: - Configure methods
private extension ConversationVC {
    func bindToPresenter() {
        self.presenter.setDelegate(self)
        self.presenter.fetchMessages(for: conversation)
        self.presenter.addObservers()
    }
    
    func configure() {
        self.view.backgroundColor = .systemBackground
        self.collectionView.backgroundColor = .systemBackground
        
        self.collectionView.register(MessageCVCell.self, forCellWithReuseIdentifier: MessageCVCell.id)
    }
    
    func configureMessageTextView() {
        self.view.addSubview(messageTextView)

        messageTextViewBottomAnchor = messageTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            messageTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            messageTextViewBottomAnchor!,
            messageTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
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
        
        NSLayoutConstraint.activate([
            chatNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatNavigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            chatNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func configureDataSource() {
        typealias DataSource = UICollectionViewDiffableDataSource<DateSection, MessageCellModel>
        dataSource = DataSource(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageCVCell.id, for: indexPath) as? MessageCVCell
            cell?.configure(with: itemIdentifier)
            return cell
        })
    }
    
    func configureLayout() {
        layout = UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
            let itemSize    = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(70))
            let item        = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let group       = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            let section     = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing       = 10
            section.contentInsets.leading   = 16
            section.contentInsets.trailing  = 16
            
            return section
        })
        
        self.collectionView.setCollectionViewLayout(layout, animated: true)
    }
}


// MARK: - ChatPresenterProtocol
extension ConversationVC: ConversationPresenterProtocol {
    func messagesDidFetch(_ messages: [MessageCellModel]) {
        update(with: messages)
    }
    
    func keyboardWillShow(height: CGFloat) {
        messageTextViewBottomAnchor?.constant = -height
        view.layoutSubviews()
    }
    
    func keyboardDidHide() {
        messageTextViewBottomAnchor?.constant = 0
        view.layoutSubviews()
    }
}
