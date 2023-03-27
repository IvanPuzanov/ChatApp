//
//  GCDService.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 17.03.2023.
//

import Foundation

protocol ConcurrentServiceProtocol: AnyObject {
    var fileService: FileService { get set }
    
    func save(user: User, completion: @escaping (Result<User, FileServiceError>) -> Void)
    func fetchUser(completion: @escaping (Result<User, Error>) -> Void)
    func cancel()
}

final class GCDService: ConcurrentServiceProtocol {
    // MARK: - Параметры
    internal var fileService: FileService = FileService.shared
    private var queue: DispatchQueue = .init(label: "queue")
    private var workItem: DispatchWorkItem?
    
    // MARK: - Методы
    func save(user: User, completion: @escaping (Result<User, FileServiceError>) -> Void) {
        workItem = DispatchWorkItem(qos: .userInitiated, flags: .noQoS, block: { [weak self] in
            sleep(2)
            guard let self else { return }
            guard let isCanceled = self.workItem?.isCancelled, !isCanceled else { return }
            
            self.fileService.save(user: user) { result in
                switch result {
                case .success(let savedUser):
                    guard let savedUser else { return }
                    completion(.success(savedUser))
                case .failure(let saveError):
                    completion(.failure(saveError))
                }
            }
            
            self.workItem = nil
        })
        
        guard let workItem else { return }
        queue.async(execute: workItem)
    }
    
    func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {
        workItem = DispatchWorkItem(qos: .userInitiated, block: { [weak self] in
            guard let self else { return }
            guard let user = self.fileService.fetchUserProfile() else {
                completion(.success(.defaultUser))
                return
            }
            completion(.success(user))
        })
    }
    
    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}
