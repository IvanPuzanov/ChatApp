//
//  Project.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import UIKit
import TFSChatTransport

enum Project {
    enum Title {
        enum Placeholder {
            static let channelName      = NSLocalizedString("Channel name", comment: "")
            static let searchChannels   = NSLocalizedString("Search channels", comment: "")
        }
        
        enum Error {
            static let noMessagesYet         = NSLocalizedString("No messages yet", comment: "")
            static let noMessagesInChat      = NSLocalizedString("There aren't messages in this chat", comment: "")
            static let channelDidntCreate    = NSLocalizedString("Channel didn't create. Try later.", comment: "")
        }
        
        enum Date {
            static let today        = NSLocalizedString("Today", comment: "")
            static let yesterday    = NSLocalizedString("Yesterday", comment: "")
        }
        
        static let chat         = NSLocalizedString("Chat", comment: "")
        static let dark         = NSLocalizedString("Dark", comment: "")
        static let light        = NSLocalizedString("Light", comment: "")
        static let system       = NSLocalizedString("System", comment: "")
        static let profile      = NSLocalizedString("Profile", comment: "")
        static let channels     = NSLocalizedString("Channels", comment: "")
        static let settings     = NSLocalizedString("Settings", comment: "")
        static let myProfile    = NSLocalizedString("My Profile", comment: "")
        static let newChannel   = NSLocalizedString("New Channel", comment: "")
        static let typeMessage  = NSLocalizedString("Type message", comment: "")
        static let editProfile  = NSLocalizedString("Edit Profile", comment: "")
    }
    
    enum Button {
        static let ok                = NSLocalizedString("Ok", comment: "")
        static let done              = NSLocalizedString("Done", comment: "")
        static let edit              = NSLocalizedString("Edit", comment: "")
        static let save              = NSLocalizedString("Save", comment: "")
        static let close             = NSLocalizedString("Close", comment: "")
        static let cancel            = NSLocalizedString("Cancel", comment: "")
        static let create            = NSLocalizedString("Create", comment: "")
        static let delete            = NSLocalizedString("Delete", comment: "")
        static let saveGCD           = NSLocalizedString("Save GCD", comment: "")
        static let addPhoto          = NSLocalizedString("Add photo", comment: "")
        static let tryAgain          = NSLocalizedString("Try again", comment: "")
        static let takePhoto         = NSLocalizedString("Take a photo", comment: "")
        static let addChannel        = NSLocalizedString("Add Channel", comment: "")
        static let editProfile       = NSLocalizedString("Edit Profile", comment: "")
        static let saveOperation     = NSLocalizedString("Save Operation", comment: "")
        static let selectFromGallery = NSLocalizedString("Select from gallery", comment: "")
    }
    
    enum Image {
        static let chats         = UIImage(systemName: "bubble.left.and.bubble.right")
        static let circle        = UIImage(systemName: "circle")
        static let arrowUp       = UIImage(systemName: "arrow.up.circle.fill")
        static let profile       = UIImage(systemName: "person.crop.circle")
        static let memoji1       = UIImage(named: "memoji1")
        static let memoji2       = UIImage(named: "memoji2")
        static let memoji3       = UIImage(named: "memoji3")
        static let settings      = UIImage(systemName: "gear")
        static let ellipsis      = UIImage(systemName: "ellipsis.circle")
        static let trayFill      = UIImage(systemName: "tray.fill")
        static let checkmark     = UIImage(systemName: "checkmark.circle.fill")
        static let darkTheme     = UIImage(named: "darkTheme")
        static let lightTheme    = UIImage(named: "lightTheme")
        static let leftGrayTail  = UIImage(named: "leftGrayTail")
        static let rightGrayTail = UIImage(named: "rightBlueTail")
        
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
        static let ooops            = NSLocalizedString("Ooops🥲", comment: "")
        static let noNameMessage    = NSLocalizedString("You can't save user without name", comment: "")
        static let wait             = NSLocalizedString("Wait!", comment: "")
        static let noConnection     = NSLocalizedString("No connection", comment: "")
        
        static func deleteChannelQuestion(channel: ChannelCellModel) -> String {
            return "Do you want to delete \(channel.name) channel?"
        }
    }
    
    enum Color {
        static let bubbleTextColor      = UIColor(named: "bubleTextColor")
        static let subviewBackground    = UIColor(named: "subviewBackground")
    }
    
    enum UserDefaultsKeys: String {
        case themeSettings = "settings"
    }
}

enum Theme: Codable {
    case light
    case dark
}
