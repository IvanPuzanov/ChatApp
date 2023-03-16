//
//  UILabel + Ex.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import UIKit

extension UILabel {
    func configure(fontSize: CGFloat, fontWeight: UIFont.Weight,
                   textColor: UIColor, textAlignment: NSTextAlignment = .center, design: UIFontDescriptor.SystemDesign = .default) {
        let systemFont = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        let roundedFont: UIFont
        if let fontDescriptor = systemFont.fontDescriptor.withDesign(design) {
            roundedFont = UIFont(descriptor: fontDescriptor, size: fontSize)
        } else {
            roundedFont = systemFont
        }
        
        self.font           = roundedFont
        self.textColor      = textColor
        self.textAlignment  = textAlignment
    }
    
    func configureNoMessagesYet(fontSize: CGFloat) {
        let italicFont  = UIFont.italicSystemFont(ofSize: fontSize)
        self.font       = italicFont
        self.textColor  = .label
    }
}
