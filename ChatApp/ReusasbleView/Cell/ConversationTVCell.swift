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
    // MARK: - Parameters
    private var conversationCellModel: ConversationCellModel?
    
    // MARK: - Views
    private let disclosureView      = UIImageView()
    private let dateLebel           = UILabel()
    private let profileImageView    = TCProfileImageView(size: .medium)
    private let activityIndicator   = UIView()
    private let nameLabel           = UILabel()
    private let messageLabel        = UILabel()
    
    // MARK: - Initialization
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
}

extension ConversationTVCell: ConfigurableViewProtocol {
    typealias ConfigurationModel = ConversationCellModel
    func configure(with model: ConversationCellModel) {
        self.nameLabel.text         = model.name
        self.dateLebel.text         = model.date?.convert(for: .conversationsList)
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
            self.dateLebel.isHidden = true
        }
    }
}

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
        activityIndicator.layer.borderColor     = UIColor.white.cgColor
        activityIndicator.backgroundColor       = .systemGreen
        activityIndicator.layer.masksToBounds   = true
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -4),
            activityIndicator.centerYAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 4),
            activityIndicator.heightAnchor.constraint(equalToConstant: 20),
            activityIndicator.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configureNameLabel() {
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.configure(fontSize: 17, fontWeight: .semibold, textColor: .label, textAlignment: .left)
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
        addSubview(dateLebel)
        dateLebel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLebel.configure(fontSize: 15, fontWeight: .regular, textColor: .secondaryLabel, textAlignment: .right)
        
        NSLayoutConstraint.activate([
            dateLebel.trailingAnchor.constraint(equalTo: disclosureView.leadingAnchor, constant: -10),
            dateLebel.centerYAnchor.constraint(equalTo: disclosureView.centerYAnchor),
            dateLebel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10)
        ])
    }
    
    
    func configureMessageLabel() {
        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.configure(fontSize: 15, fontWeight: .regular, textColor: .secondaryLabel, textAlignment: .left)
        messageLabel.numberOfLines = 2
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }
}
