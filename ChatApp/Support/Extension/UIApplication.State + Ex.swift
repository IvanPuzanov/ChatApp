//
//  UIApplication.State + Ex.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.02.2023.
//

import UIKit

extension UIApplication.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .active:
            return "Active"
        case .inactive:
            return "Inactive"
        case .background:
            return "Background"
        default:
            return ""
        }
    }
}

