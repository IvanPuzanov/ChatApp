//
//  ConversationCellModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 03.03.2023.
//

import UIKit

struct ConversationCellModel: Hashable {
    let name: String
    let message: String?
    let date: Date?
    let isOnline: Bool
    let hasUnreadMessages: Bool
    let image: UIImage?
    
    init(conversation: Conversation) {
        self.name               = conversation.name
        self.message            = conversation.message
        self.date               = conversation.date
        self.isOnline           = conversation.isOnline
        self.hasUnreadMessages  = conversation.hasUnreadMessages
        self.image              = conversation.image
    }
}
