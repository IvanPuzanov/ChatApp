//
//  ChannelsListViewModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 02.04.2023.
//

import UIKit
import Combine
import CoreData
import Network
import TFSChatTransport

enum ChannelError: String, Error {
    case createChannelDidFail   = "An error occured while creating channel"
    case deleteChannelDidFail   = "An error occured while deleting channel"
    case fetchChannelDidFail    = "An error occured while loading channels"
}

final class ChannelsListViewModel {
    // MARK: - Сервисы
    
    private let sseService: SSEService
    private let chatService: ChatService
    private let coreDataService: CoreDataServiceProtocol
    
    // MARK: - Combine
    
    private let output           = PassthroughSubject<Output, Never>()
    private var disposeBag       = Set<AnyCancellable>()
    
    // MARK: - Параметры
    
    private let moduleOutput: ChannelsListOutput
    
    private var channels         = [ChannelCellModel]()
    private var cachedChannels   = Set<ChannelCellModel>()
    private var actualChannels   = Set<ChannelCellModel>()
    
    private var isFiletered      = false
    private var filteredChannels = [ChannelCellModel]()
    
    private let monitor          = NWPathMonitor()
    private let monitorQueue     = DispatchQueue(label: "monitorQueue")
        
    // MARK: - Инициализация
    
    init(sseService: SSEService, chatService: ChatService, coreDataService: CoreDataServiceProtocol, moduleOutput: ChannelsListOutput) {
        self.sseService         = sseService
        self.chatService        = chatService
        self.coreDataService    = coreDataService
        self.moduleOutput       = moduleOutput
        
        runMonitor()
    }
}

// MARK: - View Model

extension ChannelsListViewModel: ViewModel {
    enum Input {
        case fetchChannels
        case fetchCachedChannels
        case addChannelTapped
        case filterChannels(filter: String?)
        case createChannel(name: String)
        case delete(channel: ChannelCellModel)
        case subscribeToEvents
        case showConversation(for: ChannelCellModel)
    }
    
    enum Output {
        case errorOccured(error: ChannelError)
        case fetchChannelsDidSucceeded(channels: [ChannelCellModel])
        case channelsDidFilter(channels: [ChannelCellModel])
        case createChannelDidSucceeded
        case deleteChannelDidSucceeded
        case showAddChannelAlert
        case connectionIsBroken
        case updateChannel(id: String)
    }
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .fetchChannels:
                self?.fetchChannels()
            case .fetchCachedChannels:
                self?.fetchAllCachedChannels()
            case .addChannelTapped:
                self?.output.send(.showAddChannelAlert)
            case .filterChannels(let filter):
                self?.sortChannels(with: filter)
            case .createChannel(let name):
                self?.createChannel(name: name)
            case .delete(let channel):
                self?.deleteChannel(channel)
            case .subscribeToEvents:
                self?.subscribeToEvents()
            case .showConversation(let model):
                self?.moduleOutput.showConversation(for: model)
            }
        }.store(in: &disposeBag)
        
        return output.eraseToAnyPublisher()
    }
}

// MARK: - Методы View Model

private extension ChannelsListViewModel {
    func fetchChannels() {        
        // Запрос актуальных каналов с сервера
        chatService
            .loadChannels()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.output.send(.errorOccured(error: .fetchChannelDidFail))
                }
            } receiveValue: { [weak self] channels in
                let channelViewModels = channels.map { ChannelCellModel(channel: $0) }
                
                let sortedChannels = channelViewModels.sorted { lhs, rhs in
                    return lhs.lastActivity ?? Date() > rhs.lastActivity ?? Date()
                }
            
                self?.output.send(.fetchChannelsDidSucceeded(channels: sortedChannels))
                self?.channels = sortedChannels
                self?.actualChannels = Set(sortedChannels)
                self?.updateCachedChannels()
            }.store(in: &disposeBag)

    }
    
    func createChannel(name: String) {
        chatService
            .createChannel(name: name)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.output.send(.errorOccured(error: .createChannelDidFail))
                }
            } receiveValue: { [weak self] _ in
                self?.output.send(.createChannelDidSucceeded)
                self?.fetchChannels()
            }.store(in: &disposeBag)

    }
    
    func deleteChannel(_ channel: ChannelCellModel) {
        chatService
            .deleteChannel(id: channel.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.output.send(.errorOccured(error: .deleteChannelDidFail))
                }
            } receiveValue: { [weak self] _ in
                self?.output.send(.deleteChannelDidSucceeded)
            }.store(in: &disposeBag)

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
    
    func runMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                self?.fetchChannels()
            } else {
                self?.output.send(.connectionIsBroken)
            }
        }
        
        monitor.start(queue: monitorQueue)
    }
    
    func subscribeToEvents() {
        sseService
            .subscribeOnEvents()
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] event in
                switch event.eventType {
                case .add:
                    self?.fetchChannels()
                case .delete:
                    self?.fetchChannels()
                case .update:
                    self?.fetchChannels()
                }
            }.store(in: &disposeBag)
    }
}

// MARK: - Core Data methods

extension ChannelsListViewModel {
    /// Запрос кэшированных каналов
    func fetchAllCachedChannels() {
        do {
            let fetchedCachedChannels = try coreDataService.fetchCachedChannels()
            let channelViewModels = fetchedCachedChannels.map { ChannelCellModel(channel: $0) }
           
            self.channels = channelViewModels
            self.cachedChannels = Set(channelViewModels)
            self.output.send(.fetchChannelsDidSucceeded(channels: channelViewModels))
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
