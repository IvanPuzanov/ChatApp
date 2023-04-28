//
//  MessageTextCVCell.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 07.03.2023.
//

import UIKit
import TFSChatTransport

final class MessageTextCVCell: UICollectionViewCell {
    // MARK: - UI
    
    private let stackView       = UIStackView()
    private var senderLabel     = UILabel()
    private var leftTailImage   = UIImageView()
    private var rightTailImage  = UIImageView()
    private var containerView   = UIView()
    private var messageLabel    = UILabel()
    private var dateLabel       = UILabel()
    
    // MARK: - Инициализация
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureStackView()
        configureSenderNameLabel()
        configureContainerView()
        configureLeftTailImageView()
        configureRightTailImageView()
        configureDateLabel()
        configureMessageLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Методы установки значений

extension MessageTextCVCell: ConfigurableViewProtocol {
    typealias ConfigurationModel = MessageCellModel
    func configure(with model: MessageCellModel) {
                
        let isUserMessage = model.sender == .user
        
        self.containerView.backgroundColor  = isUserMessage ? .systemBlue : .systemGray6
        self.stackView.alignment            = isUserMessage ? .trailing : .leading
        self.senderLabel.isHidden           = isUserMessage
        self.senderLabel.text               = model.userName.isEmpty ? "No name" : model.userName
        self.dateLabel.text                 = model.date.showOnlyTime()
        self.dateLabel.textColor            = isUserMessage ? .white.withAlphaComponent(0.7) : .systemGray2
        self.messageLabel.textColor         = isUserMessage ? .white : Project.Color.bubbleTextColor
        self.messageLabel.text              = model.text
        self.leftTailImage.isHidden         = isUserMessage
        self.rightTailImage.isHidden        = !isUserMessage
    }
}

// MARK: - Методы конфигурации

private extension MessageTextCVCell {
    func configureStackView() {
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
    
    func configureSenderNameLabel() {
        senderLabel = UILabelBuilder()
            .withFont(.systemFont(ofSize: 13, weight: .regular))
            .withTextColor(.secondaryLabel)
            .withAlignment(.left)
            .withNumberLines(1)
            .build()
        
        stackView.addArrangedSubview(senderLabel)
        stackView.setCustomSpacing(3, after: senderLabel)
    }
    
    func configureContainerView() {
        stackView.addArrangedSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.layer.cornerRadius    = 20
        containerView.layer.cornerCurve     = .continuous
        
        containerView.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width * 0.77).isActive = true
    }
    
    func configureLeftTailImageView() {
        self.addSubview(leftTailImage)
        leftTailImage.translatesAutoresizingMaskIntoConstraints = false
        leftTailImage.image = Project.Image.leftGrayTail
        
        NSLayoutConstraint.activate([
            leftTailImage.centerXAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            leftTailImage.centerYAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -11)
        ])
    }
    
    func configureRightTailImageView() {
        self.addSubview(rightTailImage)
        rightTailImage.translatesAutoresizingMaskIntoConstraints = false
        rightTailImage.image = Project.Image.rightGrayTail
        
        NSLayoutConstraint.activate([
            rightTailImage.centerXAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            rightTailImage.centerYAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -11)
        ])
    }
    
    func configureDateLabel() {
        dateLabel = UILabelBuilder()
            .withFont(.systemFont(ofSize: 11, weight: .regular))
            .withTextColor(.systemGray2)
            .withAlignment(.right)
            .withNumberLines(0)
            .translatesAutoresingMaskIntoConstraints(false)
            .build()
        
        self.containerView.addSubview(dateLabel)
        dateLabel.setContentCompressionResistancePriority(.init(751), for: .horizontal)
        
        NSLayoutConstraint.activate([
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    func configureMessageLabel() {
        messageLabel = UILabelBuilder()
            .withFont(.systemFont(ofSize: 15, weight: .regular))
            .withTextColor(.label)
            .withAlignment(.left)
            .withNumberLines(0)
            .translatesAutoresingMaskIntoConstraints(false)
            .build()
        
        self.containerView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -10),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -13)
        ])
    }
}
