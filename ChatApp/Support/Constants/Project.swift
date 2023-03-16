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
        static let today       = NSLocalizedString("Today", comment: "")
        static let early       = NSLocalizedString("Early", comment: "")
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
        static let arrowUp          = UIImage(systemName: "arrow.up.circle.fill")
        static let profile          = UIImage(systemName: "person.fill")
        static let settings         = UIImage(systemName: "gear")
        static let leftGrayTail     = UIImage(named: "leftGrayTail")
        static let rightGrayTail    = UIImage(named: "rightBlueTail")
        static let memoji1          = UIImage(named: "memoji1")
        static let memoji2          = UIImage(named: "memoji2")
        static let memoji3          = UIImage(named: "memoji3")
        
        static func chevronRight(configuration: UIImage.SymbolConfiguration = .init(weight: .regular)) -> UIImage {
            guard let image = UIImage(systemName: "chevron.right", withConfiguration: configuration) else { return UIImage() }
            return image
        }
    }
}
