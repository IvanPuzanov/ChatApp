//
//  TCProfileEditor.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 17.03.2023.
//

import UIKit
import Combine

final class TCProfileEditor: UIView {
    // MARK: - Publishers
    
    public var textFieldsPublisher: AnyPublisher<(name: String, bio: String), Never> {
        textFieldsSubject.eraseToAnyPublisher()
    }
    private var textFieldsSubject = PassthroughSubject<(name: String, bio: String), Never>()
    
    // MARK: - UI
    
    private let stackView       = UIStackView()
    private let topShadow       = UIView()
    private var nameLabel       = UILabel()
    private let nameTextField   = UITextField()
    private var bioLabel        = UILabel()
    private let bioTextField    = UITextField()
    private let bottomShadow    = UIView()
    
    // MARK: - Инициализация
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        configureStackView()
        configureNameField()
        configureSeparator()
        configureBioField()
        configureShadows()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Методы установки значений

extension TCProfileEditor {
    func showKeyboard(_ value: Bool) {
        switch value {
        case true:
            self.nameTextField.becomeFirstResponder()
        case false:
            self.nameTextField.resignFirstResponder()
            self.bioTextField.resignFirstResponder()
        }
    }
    
    func set(name: String?, bio: String?) {
        self.nameTextField.text = name
        self.bioTextField.text = bio
    }
    
    func enteredName() -> String? {
        return nameTextField.text
    }
    
    func enteredBio() -> String? {
        return bioTextField.text
    }
}

// MARK: - Методы конфигурации

private extension TCProfileEditor {
    func configure() {
        self.backgroundColor = Project.Color.subviewBackground
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureStackView() {
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.layoutMargins.left = 16
        stackView.isLayoutMarginsRelativeArrangement = true
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configureNameField() {
        let nameStackView = UIStackView()
        
        nameLabel = UILabelBuilder()
            .withFont(.systemFont(ofSize: 15, weight: .regular))
            .withTextColor(.label)
            .withAlignment(.left)
            .translatesAutoresingMaskIntoConstraints(false)
            .build()
        nameLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        nameStackView.addArrangedSubview(nameLabel)
        nameStackView.addArrangedSubview(nameTextField)
        nameStackView.spacing = 15
        nameStackView.layoutMargins = UIEdgeInsets(top: 11, left: 0, bottom: 11, right: 11)
        nameStackView.isLayoutMarginsRelativeArrangement = true
        
        nameLabel.text = "Name"
        nameTextField.text = "Ivan Puzanov"
        nameTextField.font = .systemFont(ofSize: 15, weight: .regular)
        
        stackView.addArrangedSubview(nameStackView)
    }
    
    func configureSeparator() {
        let separator = UIView()
        separator.backgroundColor = .separator
        stackView.addArrangedSubview(separator)
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 0.75).isActive = true
    }
    
    func configureBioField() {
        let bioStackView = UIStackView()
        
        bioLabel = UILabelBuilder()
            .withFont(.systemFont(ofSize: 15, weight: .regular))
            .withTextColor(.label)
            .withAlignment(.left)
            .translatesAutoresingMaskIntoConstraints(false)
            .build()
        bioLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        bioStackView.addArrangedSubview(bioLabel)
        bioStackView.addArrangedSubview(bioTextField)
        bioStackView.spacing = 15
        bioStackView.layoutMargins = UIEdgeInsets(top: 11, left: 0, bottom: 11, right: 11)
        bioStackView.isLayoutMarginsRelativeArrangement = true
        
        bioLabel.text = "Bio"
        bioTextField.text = "Hello! I'm an iOS Developer from Saint-Petersburg!"
        bioTextField.font = .systemFont(ofSize: 15, weight: .regular)
        
        stackView.addArrangedSubview(bioStackView)
    }
    
    func configureShadows() {
        [topShadow, bottomShadow].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .separator
        }
        
        NSLayoutConstraint.activate([
            topShadow.leadingAnchor.constraint(equalTo: leadingAnchor),
            topShadow.topAnchor.constraint(equalTo: topAnchor),
            topShadow.trailingAnchor.constraint(equalTo: trailingAnchor),
            topShadow.heightAnchor.constraint(equalToConstant: 0.75)
        ])
        
        NSLayoutConstraint.activate([
            bottomShadow.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomShadow.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomShadow.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomShadow.heightAnchor.constraint(equalToConstant: 0.75)
        ])
    }
}
