//
//  TCThemeView.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 10.03.2023.
//

import UIKit

final class TCThemeView: UIControl {
    // MARK: - Параметры
    
    public var theme: Theme
    
    // MARK: - UI
    
    private let stackView   = UIStackView()
    private let imageView   = UIImageView()
    private let titleLabel  = UILabel()
    private let indicator   = UIImageView()
    
    // MARK: - Инициализация
    
    init(theme: Theme) {
        self.theme = theme
        super.init(frame: .zero)
        
        configure()
        configureStackView()
        configureImageView(with: theme)
        configureTitleLabel(with: theme)
        configureIndicatorView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
         
    }
}

// MARK: - Обработка состояний

extension TCThemeView {
    override var isHighlighted: Bool {
        didSet {
            switch isHighlighted {
            case true:
                UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction]) {
                    self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
                }
            case false:
                UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction]) {
                    self.transform = .identity
                }
            }
        }
    }
    
    func isSelected(_ selection: Bool) {
        switch selection {
        case true:
            UIView.animate(withDuration: 0.3) {
                self.indicator.image = Project.Image.checkmark
                self.indicator.tintColor = .systemBlue
            }
        case false:
            UIView.animate(withDuration: 0.3) {
                self.indicator.image = Project.Image.circle
                self.indicator.tintColor = .separator
            }
        }
    }
}

// MARK: - Методы конфигурации

private extension TCThemeView {
    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureStackView() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis      = .vertical
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configureImageView(with theme: Theme) {
        stackView.addArrangedSubview(imageView)
        imageView.frame.size            = CGSize(width: 200, height: 140)
        imageView.contentMode           = .scaleAspectFit
        imageView.layer.cornerRadius    = 9
        imageView.layer.cornerCurve     = .continuous
        imageView.layer.borderColor     = UIColor.separator.cgColor
        imageView.layer.borderWidth     = 1
        imageView.clipsToBounds         = true
        
        switch theme {
        case .dark:
            imageView.image = Project.Image.darkTheme
        case .light:
            imageView.image = Project.Image.lightTheme
        }
    }
    
    func configureTitleLabel(with theme: Theme) {
        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(10, after: imageView)
        titleLabel.textColor = .label
        
        switch theme {
        case .dark:
            titleLabel.text = Project.Title.dark
        case .light:
            titleLabel.text = Project.Title.light
        }
    }
    
    func configureIndicatorView() {
        stackView.addArrangedSubview(indicator)
        stackView.setCustomSpacing(10, after: titleLabel)
        
        indicator.contentMode = .scaleAspectFill
        indicator.image       = Project.Image.circle
        indicator.tintColor   = .separator
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            indicator.widthAnchor.constraint(equalToConstant: 25),
            indicator.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
}
