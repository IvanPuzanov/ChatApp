//
//  ConversationPresenter.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.03.2023.
//

import UIKit

protocol ConversationPresenterProtocol: AnyObject {
    func messagesDidFetch(_ messages: [DateSection: [MessageCellModel]])
    func messagesDidFetch(_ messages: [DateComponents: [MessageCellModel]])
    func messagesDidFetch(_ messages: [MessageSnapshotModel])
    func keyboardWillShow(height: CGFloat)
    func keyboardDidHide()
}

struct MessageSnapshotModel {
    var messages: [MessageCellModel]
    var date: DateComponents
}

final class ConversationPresenter {
    // MARK: - Параметры
    private let notificationCenter = NotificationCenter.default
    typealias ChatView = ConversationPresenterProtocol & UIViewController
    private weak var view: ChatView?
    var dateComponents: [DateComponents] = []
    
    // MARK: - Инициализация
    deinit {
        removeObservers()
    }
}

// MARK: - Методы событий
extension ConversationPresenter: AnyPresenter {
    typealias PresenterType = ChatView
    func setDelegate(_ delegate: ChatView) {
        self.view = delegate
    }
    
    func fetchMessages(for conversation: ConversationCellModel?) {
        guard let conversation else { return }
        guard conversation.message != nil else { return }
        
        let sortedMessages = MessageCellModel.fetchTestMessages(for: conversation.name).sorted {
            return $0.date ?? Date() < $1.date ?? Date()
        }
        
        let groupDic = Dictionary(grouping: sortedMessages) { (value) -> DateComponents in
            let date = Calendar.current.dateComponents([.day, .year, .month], from: (value.date)!)
            return date
        }
        
        self.dateComponents = groupDic.keys.sorted { first, second in
            if let firstDate = first.date, let secondDate = second.date {
                return firstDate < secondDate
            }
            return false
        }
        
        guard !dateComponents.isEmpty else { return }
        self.view?.messagesDidFetch(groupDic)
    }
    
    func addObservers() {
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeObservers() {
        self.notificationCenter.removeObserver(self)
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? NSDictionary else { return }
        guard let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom
        
        switch bottomInset {
        case .some(let value):
            switch value {
            case 0:
                view?.keyboardWillShow(height: keyboardSize.height)
            default:
                view?.keyboardWillShow(height: keyboardSize.height - value)
            }
        default:
            break
        }
    }
    
    @objc
    private func keyboardDidHide() {
        view?.keyboardDidHide()
    }
}
