//
//  MessageCVCell.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 07.03.2023.
//

import UIKit

final class MessageCVCell: UICollectionViewCell {
    // MARK: - Параметры
    private var containerLeading: NSLayoutConstraint!
    private var containerTrailing: NSLayoutConstraint!
    
    // MARK: - UI
    private let stackView       = UIStackView()
    private var leftTailImage   = UIImageView()
    private var rightTailImage  = UIImageView()
    private var containerView   = UIView()
    private let messageLabel    = UILabel()
    private let dateLabel       = UILabel()
    
    // MARK: - Инициализация
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureStackView()
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

// MARK: -
extension MessageCVCell: ConfigurableViewProtocol {
    typealias ConfigurationModel = MessageCellModel
    func configure(with model: MessageCellModel) {
        self.messageLabel.text = model.text
        
        switch model.sender {
        case .user:
            self.dateLabel.textColor            = .white.withAlphaComponent(0.7)
            self.messageLabel.textColor         = .white
            self.containerView.backgroundColor  = .systemBlue
            
            self.rightTailImage.image = Project.Image.rightGrayTail
            self.leftTailImage.isHidden = true
            self.rightTailImage.isHidden = false
            self.stackView.alignment = .trailing
            
//            self.containerLeading.constant = UIScreen.main.bounds.width * 0.33
//            self.containerTrailing.constant = 0
        case .conversation:
            self.dateLabel.textColor            = .systemGray2
            self.messageLabel.textColor         = Project.Color.bubbleTextColor
            self.containerView.backgroundColor  = .systemGray6
            
            self.leftTailImage.image = Project.Image.leftGrayTail
            self.rightTailImage.isHidden = true
            self.leftTailImage.isHidden = false
            self.stackView.alignment = .leading
//            self.containerTrailing.constant = -UIScreen.main.bounds.width * 0.33
//            self.containerLeading.constant = 0
        }
        self.dateLabel.text = model.date?.showOnlyTime()
    }
}

// MARK: -
private extension MessageCVCell {
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
        
        NSLayoutConstraint.activate([
            leftTailImage.centerXAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            leftTailImage.centerYAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -11)
        ])
    }
    
    func configureRightTailImageView() {
        self.addSubview(rightTailImage)
        rightTailImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rightTailImage.centerXAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            rightTailImage.centerYAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -11)
        ])
    }
    
    func configureDateLabel() {
        self.containerView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.configure(fontSize: 11, fontWeight: .regular, textColor: .systemGray2, textAlignment: .right)
        dateLabel.setContentCompressionResistancePriority(.init(751), for: .horizontal)
        
        NSLayoutConstraint.activate([
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    func configureMessageLabel() {
        self.containerView.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.numberOfLines = 0
        messageLabel.configure(fontSize: 15, fontWeight: .regular, textColor: .label, textAlignment: .left)
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -10),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -13)
        ])
    }
}
