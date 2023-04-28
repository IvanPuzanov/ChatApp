//
//  DateCVHeader.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 07.03.2023.
//

import UIKit

final class DateCVHeader: UICollectionReusableView {
    // MARK: - UI
    
    private var titleLabel = UILabel()
    
    // MARK: - Инициализация
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        configureTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Методы установки значений

extension DateCVHeader: ConfigurableViewProtocol {
    typealias ConfigurationModel = DateComponents?
    func configure(with model: DateComponents?) {
        guard let model else { return }
        let calendar            = Calendar.current
        let date                = calendar.date(from: model)?.convert(for: .conversation)
        self.titleLabel.text    = date
    }
}

// MARK: - Методы конфигурации

private extension DateCVHeader {
    private func configure() {
        backgroundColor = .systemBackground
    }
    
    private func configureTitleLabel() {
        titleLabel = UILabelBuilder()
            .withFont(.systemFont(ofSize: 13, weight: .medium))
            .withTextColor(.secondaryLabel)
            .translatesAutoresingMaskIntoConstraints(false)
            .build()
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
