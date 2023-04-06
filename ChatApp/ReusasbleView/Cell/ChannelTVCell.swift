//
//  ConversationTVCell.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 03.03.2023.
//

import UIKit
import Combine
import TFSChatTransport

protocol ConfigurableViewProtocol {
    associatedtype ConfigurationModel
    func configure(with model: ConfigurationModel)
}

final class ChannelTVCell: UITableViewCell {
    // MARK: - Параметры
    
    private var channelViewModel: ChannelViewModel?
    private var input           = PassthroughSubject<ChannelViewModel.Input, Never>()
    private var cancellables    = Set<AnyCancellable>()
    
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

// MARK: - Методы установки значений

extension ChannelTVCell: ConfigurableViewProtocol {
    typealias ConfigurationModel = ChannelViewModel
    func configure(with model: ChannelViewModel) {
        self.dateLabel.text = model.lastActivity?.convert(for: .ChannelsListPresenter)
        self.profileImageView.setName(model.name)
        
        switch model.name.isEmpty {
        case true:
            self.nameLabel.text  = "Channel"
        case false:
            self.nameLabel.text  = model.name
        }
        
        switch model.lastMessage {
        case .some(let message):
            self.messageLabel.text = message
            self.messageLabel.font = .systemFont(ofSize: 15, weight: .regular)
            self.messageLabel.textColor = .secondaryLabel
            
            self.dateLabel.isHidden         = false
            self.disclosureView.isHidden    = false
        case .none:
            self.messageLabel.configureNoMessagesYet(fontSize: 15)
            self.messageLabel.text = Project.Title.Error.noMessagesYet
            
            self.dateLabel.isHidden         = true
            self.disclosureView.isHidden    = true
        }
        
        self.bindViewModel(viewModel: model)
        self.input.send(.loadImage)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.messageLabel.text          = nil
        self.dateLabel.isHidden         = false
        self.disclosureView.isHidden    = false
        self.profileImageView.setImage(nil)
        
//        self.input.send(.stopLoading)
    }
}

// MARK: - Методы конфигурации

private extension ChannelTVCell {
    func bindViewModel(viewModel: ChannelViewModel) {
        self.channelViewModel = viewModel
        
        channelViewModel?
            .transform(input.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] event in
                switch event {
                case .imageLoadSucceed(let image):
                    self?.profileImageView.setImage(image)
                case .imageLoadDidFail:
                    self?.profileImageView.setImage(nil)
                }
            }).store(in: &cancellables)
    }
    
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
        dateLabel.setContentCompressionResistancePriority(.init(760), for: .horizontal)
        
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
