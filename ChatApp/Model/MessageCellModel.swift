//
//  MessageCellModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 07.03.2023.
//

import TFSChatTransport

enum Sender {
    case interlocutor
    case user
    case none
}

struct MessageCellModel {
    let id = UUID().uuidString
    
    var sender: Sender = .none
    let userID: String
    let userName: String
    let text: String
    let date: Date
    
    init(message: Message) {
        self.text = message.text
        self.date = message.date
        self.userID = message.userID
        self.userName = message.userName
        
        guard let selfUserID = UIDevice.current.identifierForVendor?.uuidString else { return }
        switch message.userID == selfUserID {
        case true:
            self.sender = .user
        case false:
            self.sender = .interlocutor
        }
        
    }
}

extension MessageCellModel: Hashable {
    static func == (lhs: MessageCellModel, rhs: MessageCellModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {}
}
