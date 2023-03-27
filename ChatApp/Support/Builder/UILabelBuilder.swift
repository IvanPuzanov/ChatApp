//
//  UILabelBuilder.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 16.03.2023.
//

import UIKit

final class UILabelBuilder {
    // MARK: -
    private let label = UILabel()
    
    // MARK: -
    func withFont(_ font: UIFont) -> UILabelBuilder {
        label.font = font
        return self
    }
    
    func withTextColor(_ color: UIColor) -> UILabelBuilder {
        label.textColor = color
        return self
    }
    
    func withAlignment(_ alignment: NSTextAlignment) -> UILabelBuilder {
        label.textAlignment = alignment
        return self
    }
    
    func withNumberLines(_ lines: Int) -> UILabelBuilder {
        label.numberOfLines = lines
        return self
    }
    
    func translatesAutoresingMaskIntoConstraints(_ value: Bool) -> UILabelBuilder {
        label.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    func build() -> UILabel {
        return label
    }
}

