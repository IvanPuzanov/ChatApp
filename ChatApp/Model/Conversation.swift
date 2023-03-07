//
//  Conversation.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 06.03.2023.
//

import Foundation

struct Conversation {
    let name: String
    let message: String?
    let date: Date?
    let isOnline: Bool
    let hasUnreadMessages: Bool
}

#if DEBUG
extension Conversation {
    static func fetchTestConversations() -> [ConversationCellModel] {
        let conversationCellModels = [
            ConversationCellModel(conversation: Conversation(name: "Джонни", message: "I'm on my way. Meet me at the train station", date: Date(), isOnline: true, hasUnreadMessages: false)),
            ConversationCellModel(conversation: Conversation(name: "Matt", message: nil, date: nil, isOnline: true, hasUnreadMessages: false)),
            ConversationCellModel(conversation: Conversation(name: "Jason", message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis.", date: Date.createDate(day: 31, month: 12, year: 2022), isOnline: false, hasUnreadMessages: true)),
            ConversationCellModel(conversation: Conversation(name: "Jane", message: "OK", date: Date(), isOnline: false, hasUnreadMessages: false)),
            ConversationCellModel(conversation: Conversation(name: "Scott Johnson", message: "Be right back, wait for me", date: Date.createDate(day: 1, month: 8, year: 2023), isOnline: false, hasUnreadMessages: false))
        ]
        
        return conversationCellModels
    }
}
#endif
