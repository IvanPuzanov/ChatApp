//
//  TCChatNavigationBar.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.03.2023.
//

import UIKit

final class TCChatNavigationBar: UIView {
    // MARK: - UI
    private let blurredView         = UIView()
    private let profileImageView    = TCProfileImageView(size: .chat)
    private let nameLabel           = UILabel()
    private let shadowImage         = UIView()
    
    // MARK: - Инициализация
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        configureBlurredView()
        configureProfileImageView()
        configureNameLabel()
        configureShadowImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
extension TCChatNavigationBar {
    func setImage(_ image: UIImage?) {
        self.profileImageView.setImage(image)
    }
    
    func setName(_ name: String?) {
        guard let name else { return }
        self.profileImageView.setName(name)
        self.nameLabel.text = name
    }
}

// MARK: -
extension TCChatNavigationBar {
    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureBlurredView() {
        addSubview(blurredView)
        blurredView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            blurredView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurredView.topAnchor.constraint(equalTo: topAnchor),
            blurredView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurredView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        layoutSubviews()
        if !UIAccessibility.isReduceTransparencyEnabled {
            blurredView.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .prominent)
            let blurEffectView  = UIVisualEffectView(effect: blurEffect)
            
            blurEffectView.frame            = self.blurredView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            blurredView.layer.masksToBounds = true
            blurredView.addSubview(blurEffectView)
        } else {
            blurredView.backgroundColor = .systemBackground
        }
    }
    
    func configureProfileImageView() {
        self.addSubview(profileImageView)
        
        var topPadding: CGFloat = 0
        if let safeArea = UIApplication.shared.windows.first?.safeAreaInsets {
            topPadding = safeArea.top
        }
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: topPadding)
        ])
    }
    
    func configureNameLabel() {
        self.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.configure(fontSize: 11, fontWeight: .regular, textColor: .label)
        
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    func configureShadowImage() {
        self.addSubview(shadowImage)
        shadowImage.translatesAutoresizingMaskIntoConstraints = false
        
        shadowImage.backgroundColor = .separator
        
        NSLayoutConstraint.activate([
            shadowImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            shadowImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            shadowImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            shadowImage.heightAnchor.constraint(equalToConstant: 0.75)
        ])
    }
}
