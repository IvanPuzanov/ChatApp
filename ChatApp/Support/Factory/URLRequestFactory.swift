//
//  URLRequestFactory.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 28.04.2023.
//

import Foundation

enum NetworkError: Error {
    case makeRequest
    case noData
}

protocol URLRequestFactoryProtocol {
    func getImagesRequest(for page: Int) throws -> URLRequest
}

final class URLRequestFactory {
    private let host: String
    
    init(host: String) {
        self.host = host
    }
}

extension URLRequestFactory: URLRequestFactoryProtocol {
    func getImagesRequest(for page: Int) throws -> URLRequest {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "unsplash_api_key") as? String,
               let url = URL(string: "https://api.unsplash.com/photos/?client_id=\(apiKey)&page=\(page)&per_page=100")
        else {
            throw NetworkError.makeRequest
        }
        
        return URLRequest(url: url)
    }
}

private extension URLRequestFactory {
    func url(with path: String, query: String?) -> URL? {
        var urlComponents       = URLComponents()
        urlComponents.scheme    = "https"
        urlComponents.host      = host
        urlComponents.path      = path
        urlComponents.query     = query
        
        let url = urlComponents.url
        return url
    }
}
