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
    
    private let chatService     = ChatService(host: "167.235.86.234", port: 8080)
    private let output          = PassthroughSubject<Output, Never>()
    private var subcriptions    = Set<AnyCancellable>()
    
    private var user: User?
    private var userID: String? = UIDevice.current.identifierForVendor?.uuidString
    private var channel: Channel?
    
    // MARK: - Инициализация
    
    init() {
        setupKeyboardBinding()
    }
}

// MARK: - View Model

extension ConversationViewModel: ViewModel {
    enum Input {
        case fetchUser
        case fetchMessages(for: Channel)
        case loadImage
        case sendMessage(text: String)
    }
    
    enum Output {
        // Запрос сообщений
        case fetchMessagesDidFail(error: ConversationError)
        case fetchMessagesSucceed(messages: [DateComponents: [Message]])
        
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
    func fetchMessages(for channel: Channel) {
        self.channel = channel
        
        chatService
            .loadMessages(channelId: channel.id)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.output.send(.fetchMessagesDidFail(error: .fetchMessagesDidFail))
                }
            } receiveValue: { [weak self] messages in
                let sortedMessages = messages.sorted { $0.date > $1.date }
                guard let groupedMessages = self?.groupMessagesByDate(messages: sortedMessages) else { return }
                self?.output.send(.fetchMessagesSucceed(messages: groupedMessages))
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
            .sink { [weak self] notification in
                guard let userInfo = notification.userInfo as? NSDictionary else { return }
                guard let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
                let keyboardSize = keyboardInfo.cgRectValue.size
                
                let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom
                
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
            .sink { [weak self] _ in
                self?.output.send(.keyboardDidHide)
            }.store(in: &subcriptions)
    }
    
    func groupMessagesByDate(messages: [Message]) -> [DateComponents: [Message]] {
        let groupedMessages = Dictionary(grouping: messages) { (value) -> DateComponents in
            let date = Calendar.current.dateComponents([.day, .year, .month], from: (value.date))
            return date
        }
        
        return groupedMessages
    }
}
