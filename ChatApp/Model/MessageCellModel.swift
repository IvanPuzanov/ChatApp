//
//  MessageCellModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 07.03.2023.
//

import Foundation

enum Sender {
    case conversation
    case user
}

struct MessageCellModel: Hashable {
    let sender: Sender
    let text: String
    let date: Date?
}

extension MessageCellModel {
    #if DEBUG
    static func fetchTestMessages(for name: String) -> [MessageCellModel] {
        switch name.lowercased() {
        case "джонни":
            return [
                MessageCellModel(sender: .conversation, text: "Hi! I'm Jony Ive. Nice to meet you!", date: .createDate(day: 1, month: 1, year: 2023)),
                MessageCellModel(sender: .user, text: "OH MY GOD🤯", date: Date())
            ]
        case "jason":
            return [
                MessageCellModel(sender: .conversation, text: "Hi!", date: .createDate(day: 1, month: 7, year: 2022)),
                MessageCellModel(sender: .user, text: "Hello", date: .createDate(day: 8, month: 8, year: 2022)),
                MessageCellModel(sender: .conversation, text: "My name sounds like JSON, I love it!", date: .createDate(day: 1, month: 1, year: 2023)),
                MessageCellModel(sender: .user, text: "Ha-ha, it sounds pretty fun!", date: Date()),
                MessageCellModel(sender: .conversation, text: "It's true.", date: Date()),
                MessageCellModel(sender: .conversation, text: "What do you think about Xcode? What about Swift?", date: Date()),
                MessageCellModel(sender: .conversation, text: "Do you like Tinkoff's course?", date: Date()),
                MessageCellModel(sender: .user, text: "Yes, I do, absolutely perfect course!", date: Date()),
                MessageCellModel(sender: .conversation, text: "I also think so", date: Date())
            ]
        default:
            return [
                MessageCellModel(sender: .conversation, text: "Was so great to see you!", date: .createDate(day: 1, month: 1, year: 2023)),
                MessageCellModel(sender: .user, text: "Let’s get lunch soon! I’d glad to see you soon!🥳", date: Date())
            ]
        }
    }
    #endif
}
