//
//  TCPlaceholder.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.04.2023.
//

import UIKit

final class TCPlaceholder: UIStackView {
    // MARK: - Параметры
    
    // MARK: - UI
    
    private let imageView       = UIImageView()
    private var messageLabel    = UILabel()
    
    // MARK: - Инициализация
    
    convenience init() {
        self.init(frame: .zero)
        
        configure()
        configureImageView()
        configureMessageLabel()
    }
}

// MARK: - Методы установки значений

extension TCPlaceholder {
    func set(image: UIImage?, message: String) {
        self.imageView.image    = image
        self.messageLabel.text  = message
    }
}

// MARK: - Методы конфигурации

private extension TCPlaceholder {
    func configure() {
        self.axis       = .vertical
        self.alignment  = .center
        self.spacing    = 10
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureImageView() {
        self.addArrangedSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.tintColor     = .systemGray
        imageView.contentMode   = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func configureMessageLabel() {
        messageLabel = UILabelBuilder()
            .withFont(.systemFont(ofSize: 14, weight: .regular))
            .withTextColor(.secondaryLabel)
            .withAlignment(.center)
            .build()
        
        self.addArrangedSubview(messageLabel)
    }
}
