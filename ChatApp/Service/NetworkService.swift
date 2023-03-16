//
//  NetworkService.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 03.03.2023.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case badData
    case badResponse
}

protocol NetworkProtocol {
    func fetchData<T: Codable>(ofType: T.Type, from urlString: String, completion: @escaping (Result<T, NetworkError>) -> Void)
}

final class NetworkService {
    // MARK: - Parameters
    var urlSession: URLSession
    var jsonDecoder: JSONDecoder
    
    // MARK: - Initialization
    init(urlSession: URLSession = .shared, jsonDecoder: JSONDecoder = .init()) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }
}

extension NetworkService: NetworkProtocol {
    func fetchData<T: Codable>(ofType: T.Type, from urlString: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.badURL))
            return
        }
        
        let task = urlSession.dataTask(with: url) { [weak self] data, response, error in
            guard let self else { return }
            
            guard error == nil else {
                completion(.failure(.badURL))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.badResponse))
                return
            }
            
            guard let data else {
                completion(.failure(.badData))
                return
            }
            
            do {
                let decodedData = try self.jsonDecoder.decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.badData))
            }
        }
        
        task.resume()
    }
}
