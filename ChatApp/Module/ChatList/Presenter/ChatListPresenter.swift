//
//  ChatListPresenter.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import UIKit

protocol ChatListPresenterProtocol: AnyObject {
    func userProfileDidFetch(_ userProfile: UserProfile)
    func didFetchConversations(_ conversations: [ConversationCellModel])
}

final class ChatListPresenter {
    private weak var view: ChatListPresenterProtocol?
    private var conversations: [ConversationCellModel] = []
}

extension ChatListPresenter {
    func setDelegate(_ view: ChatListPresenterProtocol) {
        self.view = view
    }
    
    func fetchUserProfile() {
        view?.userProfileDidFetch(UserProfile.fetchUserProfile())
    }
    
    func fetchConversations() {
        self.conversations = Conversation.fetchTestConversations()
        view?.didFetchConversations(self.conversations)
    }
}

