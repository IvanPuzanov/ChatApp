//
//  Channel + Ex.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 03.04.2023.
//

import TFSChatTransport

extension Channel: Hashable {
    public func hash(into hasher: inout Hasher) {}
    
    public static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.id == rhs.id
    }
}
