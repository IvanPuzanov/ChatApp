//
//  MessageCVCell.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 07.03.2023.
//

import UIKit

final class MessageCVCell: UICollectionViewCell {
    // MARK: - Parameters
    private var containerLeading: NSLayoutConstraint!
    private var containerTrailing: NSLayoutConstraint!
    
    // MARK: - Views
    private var containerView   = UIView()
    private let messageLabel    = UILabel()
    private let dateLabel       = UILabel()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureContainerView()
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
            
            self.containerLeading.constant = UIScreen.main.bounds.width * 0.33
            self.containerTrailing.constant = 0
        case .conversation:
            self.dateLabel.textColor            = .systemGray2
            self.messageLabel.textColor         = .black
            self.containerView.backgroundColor  = .quaternarySystemFill
            
            self.containerTrailing.constant = -UIScreen.main.bounds.width * 0.33
            self.containerLeading.constant = 0
        }
        self.dateLabel.text = model.date?.showOnlyTime()
    }
}

// MARK: -
private extension MessageCVCell {
    func configureContainerView() {
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.layer.cornerRadius = 20
        containerView.layer.cornerCurve = .continuous
        
        containerLeading = containerView.leadingAnchor.constraint(equalTo: leadingAnchor)
        containerTrailing = containerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        
        NSLayoutConstraint.activate([
            containerLeading,
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerTrailing,
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
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
