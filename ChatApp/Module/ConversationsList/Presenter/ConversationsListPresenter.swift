//
//  ConversationsListPresenter.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import UIKit

protocol ConversationsListPresenterProtocol: AnyObject {
    func userProfileDidFetch(_ user: User)
    func didFetchConversations(_ conversations: NSDiffableDataSourceSnapshot<Section, ConversationCellModel>)
}

final class ConversationsListPresenter {
    // MARK: - Параметры
    private let fileService = FileService.shared
    private weak var view: ConversationsListPresenterProtocol?
    private var conversations: [ConversationCellModel] = []
}

// MARK: - Публичные методы
extension ConversationsListPresenter: AnyPresenter {
    typealias PresenterType = ConversationsListPresenterProtocol
    func setDelegate(_ view: ConversationsListPresenterProtocol) {
        self.view = view
    }
    
    func fetchUserProfile() {
        guard let user = fileService.fetchUserProfile() else { return }
        view?.userProfileDidFetch(user)
    }
    
    func fetchConversations() {
        self.conversations = Conversation.fetchTestConversations()
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, ConversationCellModel>()
        snapshot.appendSections([.online, .history])
        let online  = conversations.filter { $0.isOnline }
        let history = conversations.filter { !$0.isOnline }
        
        snapshot.appendItems(online, toSection: .online)
        snapshot.appendItems(history, toSection: .history)
        
        view?.didFetchConversations(snapshot)
    }
}

