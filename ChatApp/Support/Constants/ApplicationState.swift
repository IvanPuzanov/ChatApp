//
//  ApplicationState.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.02.2023.
//

import UIKit

enum ApplicationState: Int {
    case active     = 0
    case inactive   = 1
    case background = 2
    case notRunning = 3
}

extension ApplicationState: CustomStringConvertible {
    var description: String {
        switch self {
        case .notRunning:
            return "Not running"
        case .active:
            return "Active"
        case .inactive:
            return "Inactive"
        case .background:
            return "Background"
        }
    }
}
