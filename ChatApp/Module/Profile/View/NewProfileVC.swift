//
//  NewProfileVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.04.2023.
//

import UIKit
import Combine

final class NewProfileVC: UIViewController {
    // MARK: - Параметры
    
    private var viewModel       = ProfileViewModel()
    private var input           = PassthroughSubject<ProfileViewModel.Input, Never>()
    private var cancellables    = Set<AnyCancellable>()
    
    // MARK: - UI
    
    private let stackView           = UIStackView()
    private let profileImageView    = TCImageView(size: .large)
    private var nameLabel           = UILabel()
    private var bioLabel            = UILabel()
    private var editButton          = UIButton()
}

// MARK: - Жизненный цикл

extension NewProfileVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        configure()
        configureStackView()
        
        input.send(.fetchUser)
    }
}

// MARK: - Методы событий

private extension NewProfileVC {
    func bindViewModel() {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .userDidFetch(let user):
                    self?.setup(with: user)
                }
            }.store(in: &cancellables)
    }
    
    func setup(with user: User) {
        self.nameLabel.text = user.name
        self.bioLabel.text  = user.bio
    }
}

// MARK: - Методы конфигурации

private extension NewProfileVC {
    func configure() {
        self.view.backgroundColor = .secondarySystemBackground
    }
    
    func configureStackView() {
        self.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
    }
    
    func configureProfileImageView() {
        self.stackView.addArrangedSubview(profileImageView)
    }
    
    func configureNameLabel() {
        nameLabel = UILabelBuilder()
            .withFont(.systemFont(ofSize: 22, weight: .bold))
            .withTextColor(.label)
            .build()
        
        self.stackView.addArrangedSubview(nameLabel)
    }
    
    func configureBioLabel() {
        bioLabel = UILabelBuilder()
            .withFont(.systemFont(ofSize: 17, weight: .regular))
            .withTextColor(.secondaryLabel)
            .withNumberLines(3)
            .build()
        
        self.stackView.addArrangedSubview(nameLabel)
    }
    
    func configureEditButton() {
        self.stackView.addArrangedSubview(editButton)
    }
}
