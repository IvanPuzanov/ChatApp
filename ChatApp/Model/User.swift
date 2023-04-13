//
//  UserProfile.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 07.03.2023.
//

import UIKit

struct User: Codable, Equatable {
    var name: String
    var bio: String
    var avatar: Data?
}

extension User {
    static let defaultUser = User(name: "No name", bio: "No bio specified", avatar: nil)
}
