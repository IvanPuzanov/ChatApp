//
//  ConversationsListPresenter.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import Combine
import UIKit

protocol ConversationsListPresenterProtocol: AnyObject {
    func userProfileDidFetch(_ user: User)
    func didFetchConversations(_ conversations: NSDiffableDataSourceSnapshot<Section, ConversationCellModel>)
}

final class ConversationsListPresenter {
    // MARK: - Параметры
    private weak var view: ConversationsListPresenterProtocol?
    private var conversations: [ConversationCellModel] = []
    private let fileService = _FileService.shared
    private var userProfile: User = .defaultUser {
        didSet { self.view?.userProfileDidFetch(userProfile) }
    }
    
    // MARK: - Подписки
    private weak var userRequest: AnyCancellable?
}

// MARK: - Публичные методы
extension ConversationsListPresenter: AnyPresenter {
    typealias PresenterType = ConversationsListPresenterProtocol
    func setDelegate(_ view: ConversationsListPresenterProtocol) {
        self.view = view
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
    
    func createSubscriptions() {
        userRequest = fileService
            .userPublisher
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .decode(type: User.self, decoder: JSONDecoder())
            .catch({ _ in Just(User.defaultUser) })
            .assign(to: \.userProfile, on: self)
    }
    
    func fetchUser() {
        do {
            try fileService.fetchUser()
        } catch {}
    }
}

