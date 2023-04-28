//
//  ImageModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 28.04.2023.
//

import Foundation

struct ImageModel {
    var id: String
    var urls: ImageLink?
}

extension ImageModel: Codable, Hashable {
    static func == (lhs: ImageModel, rhs: ImageModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {}
}

struct ImageLink: Codable {
    var regular: String
    var small: String
    var thumb: String
}
