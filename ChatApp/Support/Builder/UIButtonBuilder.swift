//
//  UIButtonBuilder.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 14.04.2023.
//

import UIKit

final class UIButtonBuilder {
    private var button                  = UIButton()
    private var normalAttributes        = [NSAttributedString.Key: NSObject]()
    private var highlightedAttributes   = [NSAttributedString.Key: NSObject]()
    private var title                   = String()
    
    func withFont(size: CGFloat, weight: UIFont.Weight) -> UIButtonBuilder {
        self.normalAttributes[.font]         = UIFont.systemFont(ofSize: size, weight: weight)
        self.highlightedAttributes[.font]    = UIFont.systemFont(ofSize: size, weight: weight)
        
        return self
    }
    
    func withTitle(_ title: String) -> UIButtonBuilder {
        self.title = title
        
        return self
    }
    
    func withTitleColor(_ color: UIColor) -> UIButtonBuilder {
        self.normalAttributes[.foregroundColor]         = color
        self.highlightedAttributes[.foregroundColor]    = color.withAlphaComponent(0.5)
        
        return self
    }
    
    func withBackgroundColor(_ color: UIColor) -> UIButtonBuilder {
        self.button.backgroundColor = color
        
        return self
    }
    
    func withCorner(radius: CGFloat, curve: CALayerCornerCurve = .continuous) -> UIButtonBuilder {
        self.button.layer.cornerCurve   = curve
        self.button.layer.cornerRadius  = radius

        return self
    }
    
    func translatesAutoresizingMaskIntoConstraints(_ value: Bool) -> UIButtonBuilder {
        self.button.translatesAutoresizingMaskIntoConstraints = value
        
        return self
    }
    
    func addTarget(_ target: Any?, action: Selector, for event: UIControl.Event) -> UIButtonBuilder {
        button.addTarget(target, action: action, for: event)
        
        return self
    }
    
    func build() -> UIButton {
        button.setAttributedTitle(NSAttributedString(string: title, attributes: normalAttributes), for: .normal)
        button.setAttributedTitle(NSAttributedString(string: title, attributes: highlightedAttributes), for: .highlighted)
        
        return button
    }
}
