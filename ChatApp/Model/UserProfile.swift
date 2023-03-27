//
//  UserProfile.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 07.03.2023.
//

import UIKit

struct UserProfile {
    let name: String
    let description: String
    let avatar: UIImage?
}

extension UserProfile {
    #if DEBUG
    static func fetchUserProfile() -> UserProfile {
        return UserProfile(name: "Ivan Puzanov", description: "Hello! I'm an iOS Developer from Saint-Petersburg!", avatar: nil)
    }
    #endif
}

struct User: Codable {
    var name: String
    var bio: String
    var avatar: Data?
    
    enum CodingKeys: String, CodingKey {
        case name   = "name"
        case bio    = "bio"
    }
}

extension User {
    static let defaultUser = User(name: "No name", bio: "No bio specified", avatar: nil)
}
