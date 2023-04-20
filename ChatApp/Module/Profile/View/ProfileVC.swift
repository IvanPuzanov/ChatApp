//
//  NewProfileVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.04.2023.
//

import UIKit
import Combine

final class ProfileVC: UIViewController {
    // MARK: - Параметры
    
    public var coordinator: ProfileCoordinatorProtocol?
    private var viewModel       = ProfileViewModel()
    private var input           = PassthroughSubject<ProfileViewModel.Input, Never>()
    private var disposeBag      = Set<AnyCancellable>()
    
    // MARK: - UI
    
    private var stackView         = UIStackView()
    private let profileImageView  = TCImageView(size: .large)
    private var addPhotoButton    = UIButton()
    private var nameLabel         = UILabel()
    private var bioLabel          = UILabel()
    private var editButton        = UIButton()
    private var imagePicker: TCImagePicker?
}

// MARK: - Жизненный цикл

extension ProfileVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        configure()
        configureNavigationBar()
        configureStackView()
        configureProfileImageView()
        configureAddPhotoButton()
        configureNameLabel()
        configureBioLabel()
        configureEditButton()
        configureImagePicker()
        
        input.send(.fetchUser)
    }
}

// MARK: - Методы событий

extension ProfileVC {
    private func bindViewModel() {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .userDidFetch(let user):
                    self?.setup(with: user)
                case .showEditor(let user):
                    self?.coordinator?.showUserEditor(for: user)
                }
            }.store(in: &disposeBag)
    }
    
    private func setup(with user: User) {
        self.nameLabel.text = user.name
        self.bioLabel.text  = user.bio
        self.profileImageView.setName(name: user.name)
        
        guard let avatar = user.avatar, let profileImage = UIImage(data: avatar) else { return }
        self.profileImageView.setImage(image: profileImage)
    }
    
    @objc
    private func buttonTapped(_ sender: UIButton) {
        switch sender {
        case addPhotoButton:
            self.imagePicker?.present(from: addPhotoButton)
        case editButton:
            self.input.send(.showEditor)
        default:
            break
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        configure()
    }
}

// MARK: - Методы конфигурации

private extension ProfileVC {
    func configure() {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            self.view.backgroundColor = .systemBackground
        default:
            self.view.backgroundColor = .secondarySystemBackground
        }
    }
    
    func configureNavigationBar() {
        self.navigationItem.title = Project.Title.myProfile
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureStackView() {
        stackView = UIStackViewBuilder()
            .withAxis(.vertical)
            .withCorner(radius: 20)
            .withSpacing(24)
            .withAlignment(.center)
            .withMargins(top: 30, left: 20, bottom: 20, right: 20)
            .withBackgroundColor(Project.Color.subviewBackground)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build()
        
        self.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    func configureProfileImageView() {
        self.stackView.addArrangedSubview(profileImageView)
    }
    
    func configureAddPhotoButton() {
        addPhotoButton = UIButtonBuilder()
            .withFont(size: 16, weight: .regular)
            .withTitle(Project.Button.addPhoto)
            .withTitleColor(.systemBlue)
            .addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            .build()
        
        self.stackView.addArrangedSubview(addPhotoButton)
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
            .withAlignment(.center)
            .withTextColor(.secondaryLabel)
            .withNumberLines(3)
            .build()
        
        self.stackView.setCustomSpacing(10, after: nameLabel)
        self.stackView.addArrangedSubview(bioLabel)
    }
    
    func configureEditButton() {
        editButton = UIButtonBuilder()
            .withFont(size: 16, weight: .regular)
            .withTitle(Project.Button.editProfile)
            .withTitleColor(.white)
            .withBackgroundColor(.systemBlue)
            .withCorner(radius: 17)
            .addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build()
        
        self.stackView.addArrangedSubview(editButton)
        
        NSLayoutConstraint.activate([
            editButton.heightAnchor.constraint(equalToConstant: 50),
            editButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -40)
        ])
    }
    
    func configureImagePicker() {
        self.imagePicker = TCImagePicker(presentationController: self, delegate: self)
    }
}

extension ProfileVC: ImagePickerProtocol {
    func didSelect(image: UIImage?) {
        guard let image else { return }
        self.input.send(.imageDidSelect(image: image))
    }
}
