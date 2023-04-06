//
//  Conversation.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 06.03.2023.
//

import UIKit

struct Conversation {
    let name: String
    let message: String?
    let date: Date?
    let isOnline: Bool
    let hasUnreadMessages: Bool
    let image: UIImage?
}

#if DEBUG
extension Conversation {
    static func fetchTestConversations() -> [ConversationCellModel] {
        return [ConversationCellModel]()
    }
}
#endif
