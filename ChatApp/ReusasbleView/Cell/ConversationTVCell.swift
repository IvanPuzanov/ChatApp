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
    private let nameLabel           = UILabel()
    private let messageLabel        = UILabel()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureProfileImageView()
        configureDisclosureView()
        configureDateLabel()
        configureNameLabel()
        configureMessageLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ConversationTVCell: ConfigurableViewProtocol {
    typealias ConfigurationModel = ConversationCellModel
    func configure(with model: ConversationCellModel) {
        self.conversationCellModel = model
        self.profileImageView.setName(model.name)
        self.nameLabel.text = model.name
        self.dateLebel.text = model.date?.convertToMonthYearFormat()
        self.messageLabel.text = model.message ?? "No messages yet"
        
        if model.hasUnreadMessages {
            self.messageLabel.font      = .systemFont(ofSize: messageLabel.font.pointSize, weight: .semibold)
            self.messageLabel.textColor = .label
        }
        
        if model.message == nil {
            
        }
    }
}

private extension ConversationTVCell {
    func configureProfileImageView() {
        contentView.addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
    
    func configureDisclosureView() {
        contentView.addSubview(disclosureView)
        disclosureView.translatesAutoresizingMaskIntoConstraints = false
        
        disclosureView.contentMode  = .scaleAspectFit
        disclosureView.tintColor    = .secondaryLabel
        disclosureView.image        = UIImage(systemName: "chevron.right")
        
        NSLayoutConstraint.activate([
            disclosureView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            disclosureView.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            disclosureView.heightAnchor.constraint(equalToConstant: 17),
            disclosureView.widthAnchor.constraint(equalToConstant: 17),
            disclosureView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15)
        ])
    }
    
    func configureDateLabel() {
        contentView.addSubview(dateLebel)
        dateLebel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLebel.configure(fontSize: 15, fontWeight: .regular, textColor: .secondaryLabel, textAlignment: .right)
        
        NSLayoutConstraint.activate([
            dateLebel.trailingAnchor.constraint(equalTo: disclosureView.leadingAnchor, constant: -10),
            dateLebel.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
    
    func configureNameLabel() {
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.configure(fontSize: 17, fontWeight: .semibold, textColor: .label, textAlignment: .left)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(greaterThanOrEqualTo: dateLebel.leadingAnchor)
        ])
    }
    
    func configureMessageLabel() {
        contentView.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.configure(fontSize: 15, fontWeight: .regular, textColor: .secondaryLabel, textAlignment: .left)
        messageLabel.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            messageLabel.topAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])
    }
}
