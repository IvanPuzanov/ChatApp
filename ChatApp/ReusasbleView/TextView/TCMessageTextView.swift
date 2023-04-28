//
//  TCMessageTextView.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 06.03.2023.
//

import UIKit

final class TCMessageTextView: UIView {
    // MARK: - Параметры
    
    override var intrinsicContentSize: CGSize {
        return textView.intrinsicContentSize
    }
    
    public var text: String { textView.text }
    
    // MARK: - UI
    
    private let blurredView     = UIView()
    private var containerView   = UIView()
    private var placeholder     = UILabel()
    public let textView         = UITextView()
    public let imageButton      = TCSendButton()
    public let sendButton       = TCSendButton()
    
    // MARK: - Инициализация
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        configureBlurredView()
        configureImageButton()
        configureContainerView()
        configurePlaceholder()
        configureSendButton()
        configureTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Методы обработки событий

extension TCMessageTextView {
    func addImage(_ imageLink: String) {
        resetText()
        textView.insertText(imageLink)
    }
    
    func resetText() {
        textView.text           = String()
        sendButton.isActive     = false
        placeholder.isHidden    = false
    }
}

// MARK: - Методы конфигурации

private extension TCMessageTextView {
    func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
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
            
            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            blurEffectView.frame            = self.blurredView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            blurredView.layer.masksToBounds = true
            blurredView.addSubview(blurEffectView)
        } else {
            blurredView.backgroundColor = .systemBackground
        }
    }
    
    func configureImageButton() {
        self.addSubview(imageButton)
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        
        imageButton.setImage(Project.Image.camera)
        
        let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom
        
        NSLayoutConstraint.activate([
            imageButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            imageButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(bottomInset ?? 0) - 13),
            imageButton.heightAnchor.constraint(equalToConstant: 28),
            imageButton.widthAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    func configureContainerView() {
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.layer.borderWidth     = 0.75
        containerView.layer.borderColor     = UIColor.separator.cgColor
        containerView.layer.cornerRadius    = 22
//        containerView.backgroundColor       = .systemBackground
        
        let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: imageButton.trailingAnchor, constant: 10),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(bottomInset ?? 0) - 5)
        ])
    }
    
    func configurePlaceholder() {
        placeholder = UILabelBuilder()
            .withFont(.systemFont(ofSize: 15, weight: .regular))
            .withTextColor(.secondaryLabel)
            .withAlignment(.left)
            .translatesAutoresingMaskIntoConstraints(false)
            .build()
        
        self.addSubview(placeholder)
        placeholder.text = Project.Title.typeMessage
        
        NSLayoutConstraint.activate([
            placeholder.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            placeholder.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10)
        ])
    }
    
    func configureSendButton() {
        containerView.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.isActive = false
        
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            sendButton.heightAnchor.constraint(equalToConstant: 28),
            sendButton.widthAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    func configureTextView() {
        containerView.addSubview(textView)
        
        textView.font               = UIFont.systemFont(ofSize: 15)
        textView.delegate           = self
        textView.textColor          = .label
        textView.isScrollEnabled    = false
        textView.keyboardType       = .default
        textView.backgroundColor    = .clear
        textView.sizeToFit()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            textView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -5),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5)
        ])
    }
}

// MARK: - UITextViewDelegate

extension TCMessageTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let enteredText = textView.text
        let isEmpty     = enteredText?.isEmpty ?? true
        
        sendButton.isActive = !isEmpty
        placeholder.isHidden = !isEmpty
    }
}
