//
//  TCMessageTextView.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 06.03.2023.
//

import UIKit

final class TCMessageTextView: UIView {
    // MARK: - Parameters
    override var intrinsicContentSize: CGSize {
        return textView.intrinsicContentSize
    }
    
    // MARK: - Views
    public let textView     = UITextView()
    private let sendButton  = TCSendButton()
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        configureSendButton()
        configureTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Connfigure methods
private extension TCMessageTextView {
    func configure() {
        self.layer.borderWidth  = 0.75
        self.layer.borderColor  = UIColor.separator.cgColor
        self.layer.cornerRadius = 22
        
        self.backgroundColor = .white
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureSendButton() {
        addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            sendButton.heightAnchor.constraint(equalToConstant: 28),
            sendButton.widthAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    func configureTextView() {
        addSubview(textView)
        
        textView.text               = Project.Title.typeMessage
        textView.font               = UIFont.systemFont(ofSize: 15)
        textView.delegate           = self
        textView.textColor          = UIColor.lightGray
        textView.isScrollEnabled    = false
        textView.keyboardType       = .default
        
        textView.sizeToFit()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -5),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
}

// MARK: - UITextViewDelegate
extension TCMessageTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Project.Title.typeMessage
            textView.textColor = UIColor.lightGray
        }
    }
}
