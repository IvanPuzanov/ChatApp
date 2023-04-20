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
    
    public var user: User?
    public var image: UIImage?
    public var name: String?
    
    // MARK: - UI
    
    private let stackView  = UIStackView()
    private let imageView  = UIImageView()
    private let nameLabel  = UILabel()
    
    // MARK: - Инициализация
    
    init(size: Size) {
        super.init(frame: .zero)
        
        self.size = size
        
        configure()
        configureStackView()
        configureImageView()
        configureNameLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TCImageView {
    func setUser(user: User) {
        if let imageData = user.avatar {
            self.image = UIImage(data: imageData)
            self.setImage(image: self.image)
            validate()
            return
        }
        
        self.name               = user.name
        self.image              = nil
        self.imageView.image    = nil
        self.setName(name: user.name)
    
        validate()
    }
    
    func setImage(image: UIImage?) {
        self.image = image
        self.imageView.image = image
        
        validate()
    }
    
    func setName(name: String) {
        let preparedName = prepareName(name)
        
        self.name = preparedName
        self.nameLabel.text = preparedName
        
        validate()
    }
    
    func loadImage(for urlString: String?) {
        guard let urlString,
              let url = URL(string: urlString)
        else { return }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.setImage(image: image)
                    }
                }
            }
        }
    }
    
    private func validate() {
        if image != nil {
            self.nameLabel.isHidden     = true
            self.imageView.transform    = .identity
            self.imageView.isHidden     = false
        } else {
            self.nameLabel.isHidden     = false
            self.imageView.transform    = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.imageView.isHidden     = true
        }
    }
    
    private func prepareName(_ name: String) -> String {
        let splitedName = name.split(separator: " ")
        var preparedName = String()
        
        for word in splitedName {
            guard let firstChar = word.first, preparedName.count < 2 else { continue }
            preparedName.append(String(firstChar))
        }
        
        return preparedName.uppercased()
    }
}

private extension TCImageView {
    func configure() {
        clipsToBounds = true
        backgroundColor = .systemGray3
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
