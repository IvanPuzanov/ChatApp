//
//  TCSendButton.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 06.03.2023.
//

import UIKit

final class TCSendButton: UIControl {
    // MARK: - Параметры
    
    public var isActive: Bool = false {
        didSet { self.isActiveChanged() }
    }
    
    // MARK: - UI
    
    private let arrowImageView = UIImageView(image: Project.Image.arrowUp)
    
    // MARK: - Инициализация
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        configureImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Методы событий

extension TCSendButton {
    func setImage(_ image: UIImage?) {
        self.arrowImageView.image = image
    }
    
    private func isActiveChanged() {
        switch isActive {
        case true:
            UIView.animate(withDuration: 0.1) {
                self.arrowImageView.tintColor = .systemBlue
                self.isUserInteractionEnabled = true
            }
        case false:
            UIView.animate(withDuration: 0.2) {
                self.arrowImageView.tintColor = .systemGray
                self.isUserInteractionEnabled = false
            }
        }
    }
}

// MARK: - Методы конфигурации

private extension TCSendButton {
    func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureImageView() {
        self.addSubview(arrowImageView)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            arrowImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            arrowImageView.topAnchor.constraint(equalTo: topAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            arrowImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
