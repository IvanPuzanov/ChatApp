//
//  Reusable.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 06.03.2023.
//

import UIKit

protocol Reusable {
    static var id: String { get }
}

extension Reusable {
    static var id: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable {}
extension UICollectionViewCell: Reusable {}
