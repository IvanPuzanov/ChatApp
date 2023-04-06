//
//  ChannelViewModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 03.04.2023.
//

import UIKit
import Combine
import TFSChatTransport

final class ChannelViewModel {
    // MARK: - Параметры
    
    private let chatService     = ChatService(host: "167.235.86.234", port: 8080)
    private let output          = PassthroughSubject<Output, Never>()
    private var cancellabels    = Set<AnyCancellable>()
    private var imageLoadSubscription: AnyCancellable?

    private var logoImage: UIImage?
    
    // MARK: - Инициализация
    
    private let id = UUID()
    public var channel: Channel
    
    public var name: String
    public var lastMessage: String?
    public var lastActivity: Date?
    public var logoURL: String?
    
    init(channel: Channel) {
        self.channel        = channel
        self.name           = channel.name
        self.logoURL        = channel.logoURL
        self.lastMessage    = channel.lastMessage
        self.lastActivity   = channel.lastActivity
    }
}

extension ChannelViewModel: ViewModel {
    enum Input {
        case loadImage
        case stopLoading
    }
    
    enum Output {
        case imageLoadDidFail(error: Error)
        case imageLoadSucceed(image: UIImage?)
    }
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .loadImage:
                self?.loadImage()
            case .stopLoading:
                self?.stopLoading()
            }
        }.store(in: &cancellabels)

        return output.eraseToAnyPublisher()
    }
}

extension ChannelViewModel {
    private func loadImage() {
        guard let logoURL = channel.logoURL, let url = URL(string: logoURL) else { return }
        guard logoImage == nil else {
            self.output.send(.imageLoadSucceed(image: logoImage))
            return
        }
        
        imageLoadSubscription = URLSession
            .shared
            .dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global())
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.logoImage = value
                self?.output.send(.imageLoadSucceed(image: value))
            }
    }
    
    private func stopLoading() {
        imageLoadSubscription?.cancel()
        imageLoadSubscription = nil
    }
}

extension ChannelViewModel: Hashable {
    static func == (lhs: ChannelViewModel, rhs: ChannelViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {}
}
