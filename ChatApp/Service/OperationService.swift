//
//  OperationService.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 17.03.2023.
//

import Foundation

final class OperationService: ConcurrentServiceProtocol {
    internal var fileService = FileService.shared
    private var operation: TCOperation?
    private var operationQueue: OperationQueue?
    
    // MARK: -
    func save(user: User, completion: @escaping (Result<User, FileServiceError>) -> Void) {
        operation = TCOperation { [weak self] in
            sleep(2)
            guard let self else { return }
            guard let isCanceled = self.operation?.isCancelled, !isCanceled else { return }
            
            self.fileService.save(user: user) { result in
                switch result {
                case .success(let savedUser):
                    guard let savedUser else { return }
                    completion(.success(savedUser))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

        operationQueue = OperationQueue()
        guard let operation else { return }
        operationQueue?.addOperation(operation)
    }
    
    func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {
    }
    
    func cancel() {
        operation?.cancel()
        operation = nil
    }
}

// MARK: - Свой Operation
final class TCOperation: Operation {
    private var task: () -> ()
    
    init(_ task: @escaping () -> ()) {
        self.task = task
        super.init()
    }
    
    override func main() {
        super.main()
        task()
    }
}
