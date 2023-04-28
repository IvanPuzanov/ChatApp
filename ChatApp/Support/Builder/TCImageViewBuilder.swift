//
//  TCImageViewBuilder.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 24.04.2023.
//

import UIKit

final class TCImageViewBuilder {
    private var imageView = TCImageView()
    
    func withImage(_ image: UIImage?) -> TCImageViewBuilder {
        imageView.image = image
        
        return self
    }
    
    func withTintColor(_ color: UIColor) -> TCImageViewBuilder {
        imageView.tintColor = color
        
        return self
    }
    
    func withContentMode(_ mode: UIView.ContentMode) -> TCImageViewBuilder {
        imageView.contentMode = mode
        
        return self
    }
    
    func withClipsToBounds(_ value: Bool) -> TCImageViewBuilder {
        imageView.clipsToBounds = value
        
        return self
    }
    
    func withCorener(radius: CGFloat) -> TCImageViewBuilder {
        self.imageView.layer.cornerRadius  = radius
        self.imageView.layer.cornerCurve   = .continuous
        
        return self
    }
    
    func translatesAutoresizingMaskIntoConstraints(_ value: Bool) -> TCImageViewBuilder {
        imageView.translatesAutoresizingMaskIntoConstraints = value
        
        return self
    }
    
    func build() -> TCImageView {
        return imageView
    }
}
