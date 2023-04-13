//
//  ConversationViewModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 03.04.2023.
//

import Combine
import TFSChatTransport

enum ConversationError: String, Error {
    case fetchMessagesDidFail = "An error occured while loading messages"
    case sendMessageDidFail = "An error occured while sendind the message"
}

final class ConversationViewModel {
    // MARK: - Параметры
    
    private let coreDataService: CoreDataServiceProtocol = CoreDataService.shared
    private let chatService     = ChatService(host: "167.235.86.234", port: 8080)
    private let output          = PassthroughSubject<Output, Never>()
    private var subcriptions    = Set<AnyCancellable>()
    
    private var user: User?
    private var userID: String? = UIDevice.current.identifierForVendor?.uuidString
    private var channel: ChannelViewModel?
    
    private var cachedMessages = Set<MessageCellModel>()
    private var actualMessages = Set<MessageCellModel>()
    
    // MARK: - Инициализация
    
    init() {
        setupKeyboardBinding()
    }
}

// MARK: - View Model

extension ConversationViewModel: ViewModel {
    enum Input {
        case fetchUser
        case fetchMessages(for: ChannelViewModel)
        case loadImage
        case sendMessage(text: String)
    }
    
    enum Output {
        // Запрос сообщений
        case fetchMessagesDidFail(error: ConversationError)
        case fetchMessagesSucceed(messages: [DateComponents: [MessageCellModel]])
        
        case imageLoadSucceed(image: UIImage)
        
        // Отправка сообщений
        case sendMessageDidFail(error: ConversationError)
        case sendMessageSucceed
        
        // Показ/скрытие клавиатуры
        case keyboardDidShow(height: CGFloat)
        case keyboardDidHide
    }
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .fetchMessages(let channel):
                self?.fetchMessages(for: channel)
            case .loadImage:
                self?.loadImage()
            case .fetchUser:
                self?.fetchUser()
            case .sendMessage(let text):
                self?.sendMessage(text: text)
            }
        }.store(in: &subcriptions)
        
        return output.eraseToAnyPublisher()
    }
}

// MARK: - Методы View Model

private extension ConversationViewModel {
    func fetchMessages(for channel: ChannelViewModel) {
        self.fetchAllCachedMessages()
        self.channel = channel
        
        chatService
            .loadMessages(channelId: channel.id)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.output.send(.fetchMessagesDidFail(error: .fetchMessagesDidFail))
                }
            } receiveValue: { [weak self] messages in
                let sortedMessages = messages.sorted { $0.date < $1.date }
                let messageCellModels = sortedMessages.map { MessageCellModel(message: $0) }
                guard let groupedMessages = self?.groupMessagesByDate(messages: messageCellModels) else { return }
                
                self?.actualMessages = Set(messageCellModels)
                self?.output.send(.fetchMessagesSucceed(messages: groupedMessages))
                self?.updateCachedMessages()
            }.store(in: &subcriptions)

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
                self?.output.send(.imageLoadSucceed(image: image))
            }.store(in: &subcriptions)

    }
    
    func fetchUser() {
        FileService.shared
            .userPublisher
            .decode(type: User.self, decoder: JSONDecoder())
            .sink { [weak self] _ in
                self?.user = nil
            } receiveValue: { [weak self] user in
                self?.user = user
            }.store(in: &subcriptions)
        
        FileService.shared.fetchUser()
    }
    
    func sendMessage(text: String) {
        guard let channel, let user, let userID else { return }
        
        chatService
            .sendMessage(text: text, channelId: channel.id, userId: userID, userName: user.name)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.output.send(.sendMessageDidFail(error: .sendMessageDidFail))
                }
            } receiveValue: { [weak self] _ in
                self?.fetchMessages(for: channel)
            }.store(in: &subcriptions)

    }
    
    func setupKeyboardBinding() {
        NotificationCenter.default
            .publisher(for: UIApplication.keyboardWillShowNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let userInfo = notification.userInfo as? NSDictionary else { return }
                guard let keyboardFrameInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

                let keyboardSize    = keyboardFrameInfo.cgRectValue.size
                let bottomInset     = UIApplication.shared.windows.first?.safeAreaInsets.bottom

                switch bottomInset {
                case .some(let value):
                    switch value {
                    case 0:
                        self?.output.send(.keyboardDidShow(height: keyboardSize.height))
                    default:
                        self?.output.send(.keyboardDidShow(height: keyboardSize.height - value))
                    }
                default:
                    break
                }
            }.store(in: &subcriptions)

        NotificationCenter.default
            .publisher(for: UIApplication.keyboardWillHideNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.output.send(.keyboardDidHide)
            }.store(in: &subcriptions)
    }
    
    func groupMessagesByDate(messages: [MessageCellModel]) -> [DateComponents: [MessageCellModel]] {
        let groupedMessages = Dictionary(grouping: messages) { (value) -> DateComponents in
            let date = Calendar.current.dateComponents([.day, .year, .month], from: (value.date))
            return date
        }
        
        return groupedMessages
    }
}

// MARK: - Core Data methods

extension ConversationViewModel {
    func fetchAllCachedMessages() {
    }
    
    func updateCachedMessages() {
        
    }
}
