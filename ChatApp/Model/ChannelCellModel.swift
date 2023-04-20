//
//  ChannelViewModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 03.04.2023.
//

import UIKit
import Combine
import TFSChatTransport

final class ChannelCellModel {
    // MARK: - Инициализация
    
    private let uuid = UUID()
    
    public var id: String
    public var name: String
    public var lastMessage: String?
    public var lastActivity: Date?
    public var logoURL: String?
    
    public var dbChannel: DBChannel?
    
    init(channel: Channel) {
        self.id             = channel.id
        self.name           = channel.name
        self.logoURL        = channel.logoURL
        self.lastMessage    = channel.lastMessage
        self.lastActivity   = channel.lastActivity
    }
    
    init(channel: DBChannel) {
        self.id             = channel.channelID ?? UUID().uuidString
        self.name           = channel.name ?? String()
        self.logoURL        = channel.logoURL
        self.lastMessage    = channel.lastMessage
        self.lastActivity   = channel.lastActivity
        self.dbChannel      = channel
    }
}

extension ChannelCellModel: Hashable {
    static func == (lhs: ChannelCellModel, rhs: ChannelCellModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {}
}
