//
//  TCImageView.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.04.2023.
//

import UIKit

final class TCImageView: UIControl {
    // MARK: - Параметры
    
    enum Size: CGFloat {
        case small  = 30
        case medium = 45
        case chat   = 50
        case large  = 150
    }
    /// Image view size
    /// small: uses in navigation bar
    /// medium: uses in table/collection cell
    /// large: uses in profile page
    private var size: Size = .small
    
    private var image: UIImage?
    private var name: String?
    
    // MARK: - UI
    
    private let stackView           = UIStackView()
    private let imageView           = UIImageView()
    private let nameLabel           = UILabel()
    
    // MARK: - Инициализация
    
    convenience init(size: Size) {
        self.init(frame: .zero)
        
        self.size = size
        
        configure()
        configureStackView()
        configureImageView()
        configureNameLabel()
    }
}

extension TCImageView {
    func setUser(user: User) {
        if let avatarData = user.avatar, let image = UIImage(data: avatarData) {
            self.setImage(image: image)
        }
        setName(name: user.name)
    }
    
    func setImage(image: UIImage?) {
        self.image = image
        validate()
    }
    
    func setName(name: String?) {
        self.name = name
        validate()
    }
    
    private func validate() {
        switch (image, name) {
        case (image, _):
            self.imageView.isHidden = false
            self.nameLabel.isHidden = true
        case (_, name):
            self.imageView.isHidden = true
            self.nameLabel.isHidden = false
        case (_, _):
            break
        }
    }
    
    private func prepareName(name: String) {
        
    }
}

private extension TCImageView {
    func configure() {
        clipsToBounds = true
        backgroundColor = .systemGray6
        translatesAutoresizingMaskIntoConstraints = false
        
        // Image size
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: size.rawValue),
            self.heightAnchor.constraint(equalToConstant: size.rawValue)
        ])
        
        // Corner radius
        self.layer.cornerRadius = size.rawValue / 2
    }
    
    func configureStackView() {
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis                      = .vertical
        stackView.alignment                 = .center
        stackView.isUserInteractionEnabled  = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configureImageView() {
        stackView.addArrangedSubview(imageView)
        
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        imageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        imageView.isHidden = true
    }
    
    func configureNameLabel() {
        stackView.addArrangedSubview(nameLabel)
        
        let fontSize: CGFloat = size.rawValue / 2
        nameLabel.configure(fontSize: fontSize, fontWeight: .semibold, textColor: .white, design: .rounded)
    }
}
