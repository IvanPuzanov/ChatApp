//
//  GCDService.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 17.03.2023.
//

import Foundation

protocol PersistenceProtocol {
    func save(completion: @escaping (Result<String, Error>) -> Void)
    func read()
    func cancel()
}

final class GCDService: PersistenceProtocol {
    private var queue: DispatchQueue = .init(label: "queue")
    private var workItem: DispatchWorkItem?
    
    func save(completion: @escaping (Result<String, Error>) -> Void) {
        workItem = DispatchWorkItem(qos: .default, flags: .noQoS, block: {
            sleep(3)
            completion(.success("Completed"))
            self.workItem = nil
        })
        guard let workItem else { return }
        queue.async(execute: workItem)
    }
    
    func read() {
        
    }
    
    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}
