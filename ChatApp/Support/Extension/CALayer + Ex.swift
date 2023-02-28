//
//  CALayer + Ex.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 28.02.2023.
//

import UIKit

extension CALayer {
    func setGradient(with color: UIColor) {
        let colorTop        = color.withAlphaComponent(0.7).cgColor
        let colorBottom     = color.cgColor
        
        let gradientLayer       = CAGradientLayer()
        gradientLayer.frame     = bounds
        gradientLayer.colors    = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.masksToBounds = true
        
        self.insertSublayer(gradientLayer, at: 0)
    }
}
