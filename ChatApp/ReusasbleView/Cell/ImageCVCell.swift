//
//  ImageCVCell.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 28.04.2023.
//

import UIKit

final class ImageCVCell: UICollectionViewCell {
    // MARK: - Параметры
    
    public var image: UIImage? {
        return imageView.image
    }
    public var imageModel: ImageModel?
    
    // MARK: - UI
    
    private var imageView = TCImageView()
    
    // MARK: - Инициализация
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Методы установки значений

extension ImageCVCell: ConfigurableViewProtocol {
    typealias ConfigurationModel = ImageModel
    func configure(with model: ImageModel) {
        self.imageModel = model
        
        guard let urlString = model.urls?.thumb,
              let url = URL(string: urlString)
        else { return }
        
        self.imageView.loadImage(url: url)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.cancelLoading()
    }
}

// MARK: - Методы конфигурации

private extension ImageCVCell {
    func configureImageView() {
        imageView = TCImageViewBuilder()
            .withContentMode(.scaleAspectFill)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build()
        
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
