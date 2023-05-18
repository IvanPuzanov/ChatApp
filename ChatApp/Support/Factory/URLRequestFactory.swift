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
        guard // let apiKey = Bundle.main.object(forInfoDictionaryKey: "UnsplashAPIKey") as? String,
              let url = url(with: "/photos/", query: "client_id=eS1N7yFvIuMsCmwuoo0n_g26k2XwFkn4neIvAdAs_VM&page=\(page)&per_page=100")
        else {
            throw NetworkError.makeRequest
        }
        
//        print("API_KEY – \(apiKey)")
//        print("URL – \(url)")
        
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
