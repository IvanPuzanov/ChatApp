//
//  Coordinator.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.02.2023.
//

import UIKit.UINavigationController

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    
    func start()
}
