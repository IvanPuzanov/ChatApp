//
//  ServiceAssembly.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 10.10.2023.
//

import UIKit
import TFSChatTransport

final class ServiceAssembly {
    
    // MARK: - Параметры
    
    private lazy var networkService: NetworkService = {
        NetworkService()
    }()
    
    private lazy var urlRequestFacotry: URLRequestFactory = {
        URLRequestFactory(host: "api.unsplash.com")
    }()
    
    // MARK: - Методы
    
    func makeNetworkService() -> ImagesService {
        ImagesService(networkService: networkService, requestFactory: urlRequestFacotry)
    }
    
    func makeCoreDataService() -> CoreDataService {
        CoreDataService()
    }
    
    func makeSSEService() -> SSEService {
        SSEService(host: "167.235.86.234", port: 8080)
    }
    
    func makeChatService() -> ChatService {
        ChatService(host: "167.235.86.234", port: 8080)
    }
}
