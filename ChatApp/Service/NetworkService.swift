//
//  NetworkService.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 25.04.2023.
//

import UIKit
import Combine

// MARK: - NetworkService

final class NetworkService {
    private var session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

// MARK: - NetworkServiceProtocol

extension NetworkService {
    func sendRequest<T: Codable>(_ request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                
                completion(.success(model))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
