//
//  ChannelsListOutput.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 10.10.2023.
//

import UIKit

protocol ChannelsListOutput {
    func showConversation(for channel: ChannelCellModel)
}
