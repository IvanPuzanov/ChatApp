//
//  MessageImageCVCell.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 24.04.2023.
//

import UIKit

final class MessageImageCVCell: UICollectionViewCell {
    // MARK: - UI
    
    private var stackView   = UIStackView()
    private var senderLabel = UILabel()
    private var imageView   = TCImageView()
    private var dateLabel   = UILabel()
    
    // MARK: - Параметры
    
    private var stackViewTopAnchor: NSLayoutConstraint = .init()
    private var stackViewBottomAnchor: NSLayoutConstraint = .init()
    
    // MARK: - Инициализация
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureStackView()
        configureSenderLabel()
        configureImageView()
        configureDateLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Методы установки значений

extension MessageImageCVCell: ConfigurableViewProtocol {
    typealias ConfigurationModel = MessageCellModel
    func configure(with model: MessageCellModel) {
        let isUserMessage = model.sender == .user
        
        stackView.alignment     = model.sender == .user ? .trailing : .leading
        senderLabel.isHidden    = isUserMessage || model.isPreviousSelf
        senderLabel.text        = model.userName.isEmpty ? "No name" : model.userName
        dateLabel.text          = model.date.showOnlyTime()
        
        let topInset: CGFloat               = model.isPreviousSelf ? 2 : 0
        let bottomInset: CGFloat            = model.isNextSelf ? 2 : 15
        stackViewBottomAnchor.constant      = -bottomInset
        stackViewTopAnchor.constant         = topInset
        
        imageView.loadImage(urlString: model.text)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.cancelLoading()
    }
}

// MARK: - Методы конфигурации

private extension MessageImageCVCell {
    func configureStackView() {
        stackView = UIStackViewBuilder()
            .withAxis(.vertical)
            .withSpacing(5)
            .withMargins(left: 5, right: 5)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build()
        self.addSubview(stackView)
        
        stackViewTopAnchor = stackView.topAnchor.constraint(equalTo: topAnchor)
        stackViewBottomAnchor = stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackViewTopAnchor,
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackViewBottomAnchor
        ])
    }
    
    func configureSenderLabel() {
        senderLabel = UILabelBuilder()
            .withFont(.systemFont(ofSize: 13, weight: .regular))
            .withTextColor(.secondaryLabel)
            .build()
        stackView.addArrangedSubview(senderLabel)
    }
    
    func configureImageView() {
        imageView = TCImageViewBuilder()
            .withContentMode(.scaleAspectFill)
            .withClipsToBounds(true)
            .withCorener(radius: 16)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build()
        stackView.addArrangedSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 180),
            imageView.widthAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    func configureDateLabel() {
        dateLabel = UILabelBuilder()
            .withFont(.systemFont(ofSize: 11, weight: .regular))
            .withTextColor(.systemGray2)
            .build()
        
        stackView.addArrangedSubview(dateLabel)
    }
}
