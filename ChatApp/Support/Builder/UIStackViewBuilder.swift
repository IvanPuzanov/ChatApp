//
//  UIStackViewBuilder.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 14.04.2023.
//

import UIKit

final class UIStackViewBuilder {
    private var stackView = UIStackView()
}

extension UIStackViewBuilder {
    func withAxis(_ axis: NSLayoutConstraint.Axis) -> UIStackViewBuilder {
        stackView.axis = axis
        return self
    }
    
    func withAlignment(_ alignmennt: UIStackView.Alignment) -> UIStackViewBuilder {
        stackView.alignment = alignmennt
        return self
    }
    
    func withDistribution(_ distribution: UIStackView.Distribution) -> UIStackViewBuilder {
        stackView.distribution = distribution
        return self
    }
    
    func withSpacing(_ spacing: CGFloat) -> UIStackViewBuilder {
        stackView.spacing = spacing
        return self
    }
    
    func withCorner(radius: CGFloat, curve: CALayerCornerCurve = .continuous) -> UIStackViewBuilder {
        stackView.layer.cornerRadius    = radius
        stackView.layer.cornerCurve     = curve
        return self
    }
    
    func withBackgroundColor(_ color: UIColor? = .clear) -> UIStackViewBuilder {
        stackView.backgroundColor = color
        return self
    }
    
    func withMargins(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> UIStackViewBuilder {
        stackView.layoutMargins = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        stackView.isLayoutMarginsRelativeArrangement = true
        return self
    }
    
    func translatesAutoresizingMaskIntoConstraints(_ value: Bool) -> UIStackViewBuilder {
        stackView.translatesAutoresizingMaskIntoConstraints = value
        return self
    }
    
    func build() -> UIStackView {
        return stackView
    }
}
