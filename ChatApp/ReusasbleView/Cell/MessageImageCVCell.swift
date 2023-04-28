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
        stackView.alignment     = model.sender == .user ? .trailing : .leading
        senderLabel.isHidden    = model.sender == .user ? true : false
        senderLabel.text        = model.userName.isEmpty ? "No name" : model.userName
        dateLabel.text          = model.date.showOnlyTime()
        
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
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
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
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200)
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
