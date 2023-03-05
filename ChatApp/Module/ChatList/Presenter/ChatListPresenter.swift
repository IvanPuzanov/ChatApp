//
//  ChatListPresenter.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import UIKit

protocol ChatListPresenterProtocol: AnyObject {
    
}

final class ChatListPresenter {
    private weak var view: ChatListPresenterProtocol?
}

extension ChatListPresenter {
    func setDelegate(_ view: ChatListPresenterProtocol) {
        self.view = view
    }
}

