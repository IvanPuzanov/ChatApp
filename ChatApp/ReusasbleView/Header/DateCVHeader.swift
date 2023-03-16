//
//  DateCVHeader.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 07.03.2023.
//

import UIKit

final class DateCVHeader: UICollectionReusableView {
    // MARK: - Views
    private let titleLabel = UILabel()
    
    // MARK: - Initialization
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
    typealias ConfigurationModel = DateSection?
    func configure(with model: DateSection?) {
        guard let model else { return }
        switch model {
        case .today:
            self.titleLabel.text = Project.Title.today
        case .early:
            self.titleLabel.text = Project.Title.early
        }
    }
}

// MARK: - Configuration methods
private extension DateCVHeader {
    private func configure() {
        let blurEffect                  = UIBlurEffect(style: .regular)
        let blurEffectView              = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame            = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(blurEffectView)
    }
    
    private func configureTitleLabel() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.configure(fontSize: 14, fontWeight: .regular, textColor: .secondaryLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}
