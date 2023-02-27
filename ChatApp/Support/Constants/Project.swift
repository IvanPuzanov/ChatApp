//
//  Project.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import UIKit

enum Project {
    enum Title {
        static let chat         = "Chat"
        static let myProfile    = "My Profile"
    }
    
    enum Button {
        static let done 	= "Done"
        static let edit     = "Edit"
        static let close    = "Close"
        static let addPhoto = "Add photo"
    }
    
    enum Image {
        static let profile  = UIImage(systemName: "person.crop.circle.fill")
        static let settings = UIImage(systemName: "gear")
    }
}
