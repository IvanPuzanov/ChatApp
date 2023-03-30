//
//  TCProfileImageView.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import UIKit

/// Project class for showing image (usually profile image)
final class TCProfileImageView: UIControl {
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
    private var size: Size  = .small
    public var presenter = TCProfileImagePresenter()
    public var image: UIImage? {
        return imageView.image
    }
    
    // MARK: - UI
    private let stackView           = UIStackView()
    private let imageView           = UIImageView()
    private let nameLabel           = UILabel()
    
    // MARK: - Инициализация
    init(size: Size) {
        super.init(frame: .zero)
        
        self.size = size
        
        configure()
        configureStackView()
        configureImageView()
        configureNameLabel()
        
        bindToPresenter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Публичные методы
extension TCProfileImageView {
    override var bounds: CGRect {
        didSet {
            self.layer.setGradient(with: .systemGray)
        }
    }
    
    func setUser(user: User?) {
        self.presenter.user = user
    }

    func setImage(_ image: UIImage?) {
        guard let image else { return }
        self.nameLabel.isHidden = true
        self.imageView.isHidden = false
        presenter.setImage(image)
    }

    func setName(_ name: String) {
        self.presenter.setName(name)
    }
    
    func resetImage() {
        self.nameLabel.isHidden = false
        self.imageView.isHidden = true
    }
    
    func bindToPresenter() {
        self.presenter.setDelegate(self)
    }
}

// MARK: - Методы конфигурации
private extension TCProfileImageView {
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
        
        // MARK: ВРЕМЕННОЕ РЕШЕНИЕ
        // Этим будет заниматься Presenter, когда будет модель пользователя
        imageView.isHidden = true
    }
    
    func configureNameLabel() {
        stackView.addArrangedSubview(nameLabel)
        
        let fontSize: CGFloat = size.rawValue / 2
        nameLabel.configure(fontSize: fontSize, fontWeight: .semibold, textColor: .white, design: .rounded)
    }
}

extension TCProfileImageView: TCProfileImagePresenterProtocol {
    func nameDidSet(name: String) {
        DispatchQueue.main.async {
            self.imageView.isHidden = true
            self.nameLabel.isHidden = false
            
            self.nameLabel.text = name
        }
    }
    
    func imageDidSet(image: UIImage) {
        DispatchQueue.main.async {
            self.imageView.isHidden = false
            self.nameLabel.isHidden = true
            
            self.imageView.image        = image
            self.imageView.transform    = .identity
        }
    }
}
