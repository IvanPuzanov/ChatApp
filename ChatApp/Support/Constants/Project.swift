//
//  Project.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import UIKit

enum Project {
    enum Title {
        static let chat        = NSLocalizedString("Chat", comment: "")
        static let myProfile   = NSLocalizedString("My Profile", comment: "")
        static let typeMessage = NSLocalizedString("Type message", comment: "")
        static let online      = NSLocalizedString("Online", comment: "")
        static let history     = NSLocalizedString("History", comment: "")
    }
    
    enum Button {
        static let done 	            = NSLocalizedString("Done", comment: "")
        static let edit                 = NSLocalizedString("Edit", comment: "")
        static let close                = NSLocalizedString("Close", comment: "")
        static let cancel               = NSLocalizedString("Cancel", comment: "")
        static let addPhoto             = NSLocalizedString("Add photo", comment: "")
        static let takePhoto            = NSLocalizedString("Take a photo", comment: "")
        static let selectFromGallery    = NSLocalizedString("Select from gallery", comment: "")
    }
    
    enum Image {
        static let arrowUp  = UIImage(systemName: "arrow.up.circle.fill")
        static let profile  = UIImage(systemName: "person.fill")
        static let settings = UIImage(systemName: "gear")
    }
}
