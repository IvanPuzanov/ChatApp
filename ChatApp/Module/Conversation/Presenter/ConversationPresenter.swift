//
//  ConversationPresenter.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.03.2023.
//

import UIKit

protocol ConversationPresenterProtocol: AnyObject {
    func messagesDidFetch(_ messages: [MessageCellModel])
    func keyboardWillShow(height: CGFloat)
    func keyboardDidHide()
}

final class ConversationPresenter {
    // MARK: - Parameters
    private let notificationCenter = NotificationCenter.default
    typealias ChatView = ConversationPresenterProtocol & UIViewController
    private weak var view: ChatView?
    
    // MARK: - Initialization
    deinit {
        removeObservers()
    }
}

// MARK: - Event methods
extension ConversationPresenter {
    func setDelegate(_ delegate: ChatView) {
        self.view = delegate
    }
    
    func fetchMessages(for conversation: ConversationCellModel?) {
        guard let conversation else { return }
        guard conversation.message != nil else { return }
        
        var messages = MessageCellModel.fetchTestMessages(for: conversation.name).sorted {
            return $0.date ?? Date() < $1.date ?? Date()
        }
        self.view?.messagesDidFetch(messages)
    }
    
    func addObservers() {
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    func removeObservers() {
        self.notificationCenter.removeObserver(self)
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? NSDictionary else { return }
        guard let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        view?.keyboardWillShow(height: keyboardSize.height - 23)
    }
    
    @objc
    private func keyboardDidHide() {
        view?.keyboardDidHide()
    }
}
