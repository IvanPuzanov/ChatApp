//
//  DateCVHeader.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 07.03.2023.
//

import UIKit

final class DateCVHeader: UICollectionReusableView {
    // MARK: - UI
    private let titleLabel = UILabel()
    
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

// MARK: -
extension DateCVHeader: ConfigurableViewProtocol {
//    typealias ConfigurationModel = DateSection?
//    func configure(with model: DateSection?) {
//        guard let model else { return }
//        switch model {
//        case .today:
//            self.titleLabel.text = Project.Title.today
//        case .early:
//            self.titleLabel.text = Project.Title.early
//        }
//    }
    
    typealias ConfigurationModel = DateComponents
    func configure(with model: DateComponents) {
        let calendar            = Calendar.current
        let date                = calendar.date(from: model)?.convert(for: .conversationDateSection)
        self.titleLabel.text    = date
    }
}

// MARK: - Методы конфигурации
private extension DateCVHeader {
    private func configure() {
        backgroundColor = .systemBackground
    }
    
    private func configureTitleLabel() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.configure(fontSize: 14, fontWeight: .medium, textColor: .secondaryLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
