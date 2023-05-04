//
//  ConversationViewModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 03.04.2023.
//

import Combine
import TFSChatTransport

enum ConversationError: String, Error {
    case sendMessageDidFail     = "An error occured while sendind the message"
    case fetchMessagesDidFail   = "An error occured while loading messages"
}

final class ConversationViewModel {
    // MARK: - Сервисы
    
    private let sseService  = SSEService(host: "167.235.86.234", port: 8080)
    private let chatService = ChatService(host: "167.235.86.234", port: 8080)
    private let coreDataService: CoreDataServiceProtocol
    private let notificationCenter: NotificationCenter = .default
    
    // MARK: - Параметры
    
    private let output          = PassthroughSubject<Output, Never>()
    private var disposeBag      = Set<AnyCancellable>()
    
    private var user: User?
    private var userID: String? = UIDevice.current.identifierForVendor?.uuidString
    public weak var channel: ChannelCellModel?
    
    private var cachedMessages = Set<MessageCellModel>()
    private var actualMessages = Set<MessageCellModel>()
    
    // MARK: - Инициализация
    
    init(coreDataService: CoreDataServiceProtocol = CoreDataService.shared) {
        self.coreDataService = coreDataService
    }
}

// MARK: - View Model

extension ConversationViewModel: ViewModel {
    enum Input {
        case fetchUser
        case loadImage
        case fetchMessages
        case removeSubcription
        case subscribeOnEvents
        case fetchCachedMessages
        case subscribeKeyboardEvents
        case addImage(image: UIImage)
        case sendMessage(text: String)
    }
    
    enum Output {
        case keyboardDidHide
        case sendMessageSucceeded
        case keyboardDidShow(height: CGFloat)
        case imageLoadSucceeded(image: UIImage)
        case errorOccured(error: ConversationError)
        case fetchMessagesSucceeded(messages: [DateComponents: [MessageCellModel]])
    }
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .fetchMessages:
                self?.fetchMessages()
            case .fetchCachedMessages:
                self?.fetchAllCachedMessages()
            case .loadImage:
                self?.loadImage()
            case .fetchUser:
                self?.fetchUser()
            case .sendMessage(let text):
                self?.sendMessage(text: text)
            case .addImage:
                break
            case .subscribeKeyboardEvents:
                self?.subscribeKeyboardEvents()
            case .subscribeOnEvents:
                self?.subscribeOnEvents()
            case .removeSubcription:
                self?.sseService.cancelSubscription()
            }
        }.store(in: &disposeBag)
        
        return output.eraseToAnyPublisher()
    }
}

// MARK: - Методы View Model

private extension ConversationViewModel {
    func fetchMessages() {
        guard let channel else { return }
        
        chatService
            .loadMessages(channelId: channel.id)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.output.send(.errorOccured(error: .fetchMessagesDidFail))
                }
            } receiveValue: { [weak self] messages in
                let messageCellModels       = messages.map { MessageCellModel(message: $0) }
                guard let groupedMessages   = self?.groupMessagesByDate(messages: messageCellModels) else { return }
                
                self?.output.send(.fetchMessagesSucceeded(messages: groupedMessages))
                self?.actualMessages = Set(messageCellModels)
                self?.updateCachedMessages()
            }.store(in: &disposeBag)

    }
    
    func loadImage() {
        guard let channel else { return }
        guard let logoURL = channel.logoURL, let url = URL(string: logoURL) else { return }
        
        URLSession
            .shared
            .dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let image else { return }
                self?.output.send(.imageLoadSucceeded(image: image))
            }.store(in: &disposeBag)

    }
    
    func fetchUser() {
        FileService.shared
            .userPublisher
            .decode(type: User.self, decoder: JSONDecoder())
            .sink { [weak self] _ in
                self?.user = nil
            } receiveValue: { [weak self] user in
                self?.user = user
            }.store(in: &disposeBag)
        
        FileService.shared.fetchUser()
    }
    
    func sendMessage(text: String) {
        guard let channel, let user, let userID else { return }
        
        chatService
            .sendMessage(text: text, channelId: channel.id, userId: userID, userName: user.name)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.output.send(.errorOccured(error: .sendMessageDidFail))
                }
            } receiveValue: { [weak self] _ in
                self?.output.send(.sendMessageSucceeded)
                self?.fetchMessages()
            }.store(in: &disposeBag)

    }
    
    func subscribeKeyboardEvents() {
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? NSDictionary else { return }
        guard let keyboardFrameInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardSize = keyboardFrameInfo.cgRectValue.size
        let bottomInset  = UIApplication.shared.windows.first?.safeAreaInsets.bottom

        switch bottomInset {
        case .some(let value):
            switch value {
            case 0:
                self.output.send(.keyboardDidShow(height: keyboardSize.height))
            default:
                self.output.send(.keyboardDidShow(height: keyboardSize.height - value))
            }
        default:
            break
        }
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification) {
        self.output.send(.keyboardDidHide)
    }
    
    func groupMessagesByDate(messages: [MessageCellModel]) -> [DateComponents: [MessageCellModel]] {
        var preparedMessages = [MessageCellModel]()
        messages.enumerated().forEach { index, message in
            let nextIndex       = index + 1
            let previousIndex   = index - 1
            
            var newMessage = message
            if messages.indices.contains(previousIndex) && messages[previousIndex].userID == message.userID {
                newMessage.isPreviousSelf = true
            }
            if messages.indices.contains(nextIndex) && messages[nextIndex].userID == message.userID {
                newMessage.isNextSelf = true
            }
            preparedMessages.append(newMessage)
        }
        
        let groupedMessages = Dictionary(grouping: preparedMessages) { (value) -> DateComponents in
            let date = Calendar.current.dateComponents([.day, .year, .month], from: (value.date))
            return date
        }
        
        return groupedMessages
    }
    
    func subscribeOnEvents() {
        guard let channel else { return }
        
        sseService
            .subscribeOnEvents()
            .sink { [weak self] _ in
                self?.output.send(.errorOccured(error: .fetchMessagesDidFail))
            } receiveValue: { [weak self] event in
                switch event.resourceID {
                case channel.id:
                    self?.fetchMessages()
                default:
                    break
                }
            }.store(in: &disposeBag)

    }
}

// MARK: - Core Data methods

extension ConversationViewModel {
    func fetchAllCachedMessages() {        
        guard let channelID = channel?.id else { return }
        do {
            let fetchedCachedMessages = try coreDataService.fetchCachedMessages(for: channelID).map { MessageCellModel(message: $0) }
            let sortedCachedMessages = fetchedCachedMessages.sorted(by: { return $0.date < $1.date })
            let groupedMessages = self.groupMessagesByDate(messages: sortedCachedMessages)
            
            self.cachedMessages = Set(sortedCachedMessages)
            
            self.output.send(.fetchMessagesSucceeded(messages: groupedMessages))
        } catch {  }
    }
    
    func updateCachedMessages() {
        guard let channelID = channel?.id else { return }
        
        let messagesToCache = actualMessages.subtracting(cachedMessages)

        messagesToCache.forEach { message in
            coreDataService.save { context in
                let fetchRequest = DBChannel.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "channelID == %@", channelID as CVarArg)
                let channelMO = try context.fetch(fetchRequest).first

                guard let channelMO else { return }

                let messageMO       = DBMessage(context: context)
                messageMO.date      = message.date
                messageMO.text      = message.text
                messageMO.userID    = message.userID
                messageMO.userName  = message.userName

                channelMO.addToMessages(messageMO)
            }
        }
    }
}
