//
//  ConversationTVCell.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 03.03.2023.
//

import UIKit

protocol ConfigurableViewProtocol {
    associatedtype ConfigurationModel
    func configure(with model: ConfigurationModel)
}

final class ConversationTVCell: UITableViewCell {
    // MARK: - Параметры
    private var conversationCellModel: ConversationCellModel?
    
    // MARK: - UI
    private let disclosureView      = UIImageView()
    private var dateLabel           = UILabel()
    private let profileImageView    = TCProfileImageView(size: .medium)
    private let activityIndicator   = UIView()
    private var nameLabel           = UILabel()
    private var messageLabel        = UILabel()
    
    // MARK: - Инициализация
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureProfileImageView()
        configureActivityIndicator()
        configureNameLabel()
        configureDisclosureView()
        configureDateLabel()
        configureMessageLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.activityIndicator.layer.borderColor = UIColor.systemBackground.cgColor
    }
}

// MARK: -
extension ConversationTVCell: ConfigurableViewProtocol {
    typealias ConfigurationModel = ConversationCellModel
    func configure(with model: ConversationCellModel) {
        self.nameLabel.text         = model.name
        self.dateLabel.text         = model.date?.convert(for: .conversationsList)
        self.messageLabel.text      = model.message ?? "No messages yet"
        self.conversationCellModel  = model
        self.profileImageView.setName(model.name)
        self.profileImageView.setImage(model.image)
        
        if model.hasUnreadMessages {
            self.messageLabel.font      = .systemFont(ofSize: messageLabel.font.pointSize, weight: .medium)
            self.messageLabel.textColor = .label
        }
        
        switch model.isOnline {
        case true:
            activityIndicator.backgroundColor   = .systemGreen
            activityIndicator.layer.borderWidth = 3
        case false:
            activityIndicator.backgroundColor   = .clear
            activityIndicator.layer.borderWidth = 0
        }
        
        if model.message == nil {
            self.messageLabel.configureNoMessagesYet(fontSize: 15)
            self.disclosureView.isHidden = true
            self.dateLabel.isHidden = true
        }
    }
}

// MARK: -
private extension ConversationTVCell {
    func configureProfileImageView() {
        addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
        ])
    }
    
    func configureActivityIndicator() {
        self.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.layer.cornerRadius    = 10
        activityIndicator.layer.borderWidth     = 3
        activityIndicator.layer.borderColor     = UIColor.systemBackground.cgColor
        activityIndicator.backgroundColor       = .systemGreen
        activityIndicator.layer.masksToBounds   = true
        activityIndicator.layer.allowsEdgeAntialiasing = true
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -4),
            activityIndicator.centerYAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 4),
            activityIndicator.heightAnchor.constraint(equalToConstant: 20),
            activityIndicator.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configureNameLabel() {
        nameLabel = UILabelBuilder()
            .withFont(.systemFont(ofSize: 17, weight: .semibold))
            .withTextColor(.label)
            .withAlignment(.left)
            .translatesAutoresingMaskIntoConstraints(false)
            .build()
        
        addSubview(nameLabel)
        nameLabel.setContentCompressionResistancePriority(.init(760), for: .vertical)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15)
        ])
    }
    
    func configureDisclosureView() {
        addSubview(disclosureView)
        disclosureView.translatesAutoresizingMaskIntoConstraints = false
        
        disclosureView.contentMode  = .scaleAspectFit
        disclosureView.tintColor    = .lightGray
        disclosureView.image        = Project.Image.chevronRight(configuration: .init(weight: .semibold))
        
        NSLayoutConstraint.activate([
            disclosureView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            disclosureView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            disclosureView.heightAnchor.constraint(equalToConstant: 17),
            disclosureView.widthAnchor.constraint(equalToConstant: 17)
        ])
    }
    
    func configureDateLabel() {
        dateLabel = UILabelBuilder()
            .withFont(.systemFont(ofSize: 15, weight: .regular))
            .withTextColor(.secondaryLabel)
            .withAlignment(.right)
            .translatesAutoresingMaskIntoConstraints(false)
            .build()
        
        addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.trailingAnchor.constraint(equalTo: disclosureView.leadingAnchor, constant: -10),
            dateLabel.centerYAnchor.constraint(equalTo: disclosureView.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10)
        ])
    }
    
    
    func configureMessageLabel() {
        messageLabel = UILabelBuilder()
            .withFont(.systemFont(ofSize: 15, weight: .regular))
            .withTextColor(.secondaryLabel)
            .withAlignment(.left)
            .withNumberLines(2)
            .translatesAutoresingMaskIntoConstraints(false)
            .build()
        
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }
}
