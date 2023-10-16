//
//  TCNavigationBar.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.03.2023.
//

import UIKit

final class TCNavigationBar: UINavigationBar {
    var navigationItemsOffset: CGPoint = CGPoint(x: 0, y: 10) { // default offset (below statusbar)
        didSet {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.setNeedsLayout()
            }
        }
    }
    
    var barHeight: CGFloat = 60 { // default height
        didSet {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.sizeToFit()
                self?.setNeedsLayout()
            }
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: barHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        frame.origin = navigationItemsOffset
        
        subviews.forEach { (subview) in
            subview.center.y = center.y
        }
    }
}
