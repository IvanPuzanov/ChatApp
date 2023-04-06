//
//  UIButton + Ex.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import UIKit

extension UIButton {
    func configure(title: String, fontSize: CGFloat, fontWeight: UIFont.Weight, titleColor: UIColor) {
        let normalAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight),
            NSAttributedString.Key.foregroundColor: titleColor
        ]
        let highlightAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight),
            NSAttributedString.Key.foregroundColor: titleColor.withAlphaComponent(0.5)
        ]
        self.setAttributedTitle(NSAttributedString(string: title, attributes: normalAttributes), for: .normal)
        self.setAttributedTitle(NSAttributedString(string: title, attributes: highlightAttributes), for: .highlighted)
    }
}
