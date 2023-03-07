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
