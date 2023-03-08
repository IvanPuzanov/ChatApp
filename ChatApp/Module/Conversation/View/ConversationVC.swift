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
    func update(with messages: [DateSection: [MessageCellModel]]) {
        var snapshot = NSDiffableDataSourceSnapshot<DateSection, MessageCellModel>()
        
        snapshot.appendSections([.early, .today])
        
        if let earlyMessages = messages[.early] {
            snapshot.appendItems(earlyMessages, toSection: .early)
        }
        if let todayMessages = messages[.today] {
            snapshot.appendItems(todayMessages, toSection: .today)
        }
        
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
        self.collectionView.keyboardDismissMode = .onDrag
        
        self.collectionView.register(MessageCVCell.self, forCellWithReuseIdentifier: MessageCVCell.id)
        self.collectionView.register(DateCVHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DateCVHeader.id)
    }
    
    func configureMessageTextView() {
        self.view.addSubview(messageTextView)
        
        messageTextViewBottomAnchor = messageTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            messageTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageTextViewBottomAnchor!,
            messageTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
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
        typealias DataSource = UICollectionViewDiffableDataSource<DateSection, MessageCellModel>
        dataSource = DataSource(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageCVCell.id, for: indexPath) as? MessageCVCell
            cell?.configure(with: itemIdentifier)
            return cell
        })
        
        dataSource.supplementaryViewProvider = { [unowned self] _, _, indexPath in
            if let cell = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                               withReuseIdentifier: DateCVHeader.id,
                                                                               for: indexPath) as? DateCVHeader {
                cell.configure(with: DateSection(rawValue: indexPath.section))
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
            let section     = NSCollectionLayoutSection(group: group)
            //            section.interGroupSpacing       = 5
            section.contentInsets.leading   = 16
            section.contentInsets.trailing  = 16
            
            typealias SupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem
            let layoutSize      = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
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
    func messagesDidFetch(_ messages: [DateSection: [MessageCellModel]]) {
        update(with: messages)
    }
    
    func keyboardWillShow(height: CGFloat) {
        messageTextViewBottomAnchor?.constant = -height
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        view.layoutSubviews()
    }
    
    func keyboardWillHide() {
        messageTextViewBottomAnchor?.constant = -10
        view.layoutSubviews()
    }
}
