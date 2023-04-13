//
//  ChannelsListViewModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 02.04.2023.
//

import UIKit
import Combine
import CoreData
import TFSChatTransport

enum ChannelError: String, Error {
    case createChannelDidFail   = "An error occured while creating channel"
    case deleteChannelDidFail   = "An error occured while deleting channel"
    case fetchChannelDidFail    = "An error occured while loading channels"
}

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}

final class ChannelsListViewModel {
    private let coreDataService: CoreDataServiceProtocol = CoreDataService.shared
    private let chatService         = ChatService(host: "167.235.86.234", port: 8080)
    private let output              = PassthroughSubject<Output, Never>()
    private var cancellabels        = Set<AnyCancellable>()
    
    private var channels            = [ChannelViewModel]()
    private var cachedChannels      = Set<ChannelViewModel>()
    private var actualChannels      = Set<ChannelViewModel>()
    
    private var isFiletered         = false
    private var filteredChannels    = [ChannelViewModel]()
}

// MARK: - View Model

extension ChannelsListViewModel: ViewModel {
    enum Input {
        case fetchChannels
        case addChannelTapped
        case filterChannels(filter: String?)
        case createChannel(name: String)
        case delete(channel: ChannelViewModel)
    }
    
    enum Output {
        case fetchChannelsDidFail(error: ChannelError)
        case fetchChannelsDidSucceed(channels: [ChannelViewModel])
        
        case channelsDidFilter(channels: [ChannelViewModel])
        
        case showAddChannelAlert
        
        case createChannelDidFail(error: ChannelError)
        case createChannelDidSucceed
        
        case deleteChannelDidFail(error: ChannelError)
        case deleteChannelDidSucceed
    }
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .fetchChannels:
                self?.fetchChannels()
            case .addChannelTapped:
                self?.output.send(.showAddChannelAlert)
            case .filterChannels(let filter):
                self?.sortChannels(with: filter)
            case .createChannel(let name):
                self?.createChannel(name: name)
            case .delete(let channel):
                self?.deleteChannel(channel)
            }
        }.store(in: &cancellabels)
        
        return output.eraseToAnyPublisher()
    }
}

// MARK: - Методы View Model

private extension ChannelsListViewModel {
    func fetchChannels() {
        // Запрос кэшированных каналов
        self.fetchAllCachedChannels()
        
        // Запрос актуальных каналов с сервера
        chatService
            .loadChannels()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.output.send(.fetchChannelsDidFail(error: .fetchChannelDidFail))
                }
            } receiveValue: { [weak self] channels in
                let channelViewModels = channels.map { ChannelViewModel(channel: $0) }
                
                let sortedChannels = channelViewModels.sorted { lhs, rhs in
                    return lhs.lastActivity ?? Date() > rhs.lastActivity ?? Date()
                }
                
                self?.channels = sortedChannels
                self?.actualChannels = Set(sortedChannels)
                self?.output.send(.fetchChannelsDidSucceed(channels: sortedChannels))
                self?.updateCachedChannels()
            }.store(in: &cancellabels)

    }
    
    func createChannel(name: String) {
        chatService
            .createChannel(name: name)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.output.send(.createChannelDidFail(error: .createChannelDidFail))
                }
            } receiveValue: { [weak self] _ in
                self?.output.send(.createChannelDidSucceed)
                self?.fetchChannels()
            }.store(in: &cancellabels)

    }
    
    func deleteChannel(_ channel: ChannelViewModel) {
        chatService
            .deleteChannel(id: channel.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.output.send(.deleteChannelDidFail(error: .deleteChannelDidFail))
                }
            } receiveValue: { [weak self] _ in
                self?.output.send(.deleteChannelDidSucceed)
            }.store(in: &cancellabels)

    }
    
    func sortChannels(with keyword: String?) {
        guard let keyword, !keyword.isEmpty else {
            self.filteredChannels = []
            self.output.send(.channelsDidFilter(channels: channels))
            return
        }
        
        filteredChannels = channels.filter { $0.name.lowercased().contains(keyword.lowercased()) }
        let sortedChannels = filteredChannels.sorted { lhs, rhs in
            guard let firstDate = lhs.lastActivity, let secondDate = rhs.lastActivity else { return false }
            return firstDate > secondDate
        }
        self.output.send(.channelsDidFilter(channels: sortedChannels))
    }
}

// MARK: - Core Data methods

extension ChannelsListViewModel {
    /// Запрос кэшированных каналов
    func fetchAllCachedChannels() {
        do {
            let fetchedCachedChannels = try coreDataService.fetchCachedChannels()
            let channelViewModels = fetchedCachedChannels.map { ChannelViewModel(channel: $0) }
            
            self.channels = channelViewModels
            self.cachedChannels = Set(channelViewModels)
            self.output.send(.fetchChannelsDidSucceed(channels: channelViewModels))
        } catch {}
    }
    
    /// Обновление кэшированных каналов
    func updateCachedChannels() {
        let channelsToCache = actualChannels.subtracting(cachedChannels)
        let channelsToDelete = cachedChannels.subtracting(actualChannels)
        
        channelsToCache.forEach { model in
            coreDataService.save { context in
                let channelMO           = DBChannel(context: context)
                channelMO.channelID     = model.id
                channelMO.name          = model.name
                channelMO.logoURL       = model.logoURL
                channelMO.lastMessage   = model.lastMessage
                channelMO.lastActivity  = model.lastActivity
            }
        }
    
        channelsToDelete.forEach { channel in
            coreDataService.delete { context in
                guard let managedObject = channel.dbChannel else { return }
                context.delete(managedObject)
                try context.save()
            }
        }
    }
}
