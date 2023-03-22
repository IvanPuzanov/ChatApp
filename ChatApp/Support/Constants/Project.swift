//
//  Project.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import UIKit

enum Project {
    enum Title {
        static let chat         = NSLocalizedString("Chat", comment: "")
        static let myProfile    = NSLocalizedString("My Profile", comment: "")
        static let typeMessage  = NSLocalizedString("Type message", comment: "")
        static let online       = NSLocalizedString("Online", comment: "")
        static let history      = NSLocalizedString("History", comment: "")
        static let today        = NSLocalizedString("Today", comment: "")
        static let early        = NSLocalizedString("Early", comment: "")
        static let settings     = NSLocalizedString("Settings", comment: "")
        static let dark         = NSLocalizedString("Dark", comment: "")
        static let light        = NSLocalizedString("Light", comment: "")
        static let system       = NSLocalizedString("System", comment: "")
    }
    
    enum Button {
        static let ok                   = NSLocalizedString("Ok", comment: "")
        static let done 	            = NSLocalizedString("Done", comment: "")
        static let edit                 = NSLocalizedString("Edit", comment: "")
        static let close                = NSLocalizedString("Close", comment: "")
        static let cancel               = NSLocalizedString("Cancel", comment: "")
        static let addPhoto             = NSLocalizedString("Add photo", comment: "")
        static let tryAgain             = NSLocalizedString("Try again", comment: "")
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
        static let checkmark        = UIImage(systemName: "checkmark.circle.fill")
        static let circle           = UIImage(systemName: "circle")
        static let darkTheme        = UIImage(named: "darkTheme")
        static let lightTheme       = UIImage(named: "lightTheme")
        
        static func chevronRight(configuration: UIImage.SymbolConfiguration = .init(weight: .regular)) -> UIImage {
            guard let image = UIImage(systemName: "chevron.right", withConfiguration: configuration) else { return UIImage() }
            return image
        }
    }
    
    enum AlertTitle {
        static let success          = NSLocalizedString("Success🥳", comment: "")
        static let successMesssage  = NSLocalizedString("You are breathtaking", comment: "")
        static let failure          = NSLocalizedString("Something went worng😢", comment: "")
        static let failureMessage   = NSLocalizedString("Could not save profile", comment: "")
    }
    
    enum Color {
        static let bubbleTextColor      = UIColor(named: "bubleTextColor")
        static let subviewBackground    = UIColor(named: "subviewBackground")
    }
    
    enum UserDefaultsKeys: String {
        case settings = "settings"
    }
}

enum Theme: Codable {
    case light
    case dark
}
