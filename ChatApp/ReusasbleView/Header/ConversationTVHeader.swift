//
//  ConversationTVHeader.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.03.2023.
//

import UIKit

final class ConversationTVHeader: UIControl {
    // MARK: - UI
    private let titleLabel      = UILabel()
    private let shadowImage     = UIView()
    
    // MARK: - Инициализация
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureTitleLabel()
        configureShadowImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
extension ConversationTVHeader {
    func configure(with title: String?) {
        self.titleLabel.text = title
    }
    
    func configure(with section: Section) {
        self.titleLabel.text = section.rawValue.uppercased()
    }
}

// MARK: - Методы конфигурации
private extension ConversationTVHeader {
    func configureTitleLabel() {
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .systemBackground
        titleLabel.configure(fontSize: 15, fontWeight: .semibold, textColor: .secondaryLabel, textAlignment: .left)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func configureShadowImage() {
        self.addSubview(shadowImage)
        shadowImage.translatesAutoresizingMaskIntoConstraints = false
        
        shadowImage.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            shadowImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            shadowImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1),
            shadowImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            shadowImage.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
