//
//  NetworkService.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 03.03.2023.
//

import UIKit
import Combine

enum NetworkError: Error {
    case badURL
    case badData
    case badResponse
}

final class NetworkService {
    // MARK: - Параметры
    
    var urlSession: URLSession
    var jsonDecoder: JSONDecoder
    
    // MARK: - Инициализация
    
    init(urlSession: URLSession = .shared, jsonDecoder: JSONDecoder = .init()) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }
}
