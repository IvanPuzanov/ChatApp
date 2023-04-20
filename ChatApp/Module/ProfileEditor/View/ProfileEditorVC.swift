//
//  ProfileEditorVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 18.04.2023.
//

import UIKit
import Combine

final class ProfileEditorVC: UIViewController {
    // MARK: - Параметры
    
    public var user: User  = .defaultUser
    private var viewModel  = ProfileEditorViewModel()
    
    // MARK: - Combine
    
    private var input      = PassthroughSubject<ProfileEditorViewModel.Input, Never>()
    private var disposeBag = Set<AnyCancellable>()
    
    // MARK: - UI
    
    public let stackView          = UIStackView()

    public var cancelButton       = UIBarButtonItem()
    public var saveButton         = UIBarButtonItem()
    public var activity           = UIActivityIndicatorView(style: .medium)
    
    public let profileImageView   = TCImageView(size: .large)
    public let addPhotoButton     = UIButton()
    public let profileEditor      = TCProfileEditor()
    
    private var imagePicker: TCImagePicker?
}

// MARK: - Жизненный цикл

extension ProfileEditorVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        configure()
        configureNavigationBar()
        configureStackView()
        configureProfileImageView()
        configureAddPhotoButton()
        configureProfileEditor()
        configureImagePicker()
        
        setup(with: user)
    }
}

// MARK: - Методы обработки событий

private extension ProfileEditorVC {
    @objc
    func buttonTapped(_ button: UIControl) {
        switch button {
        case addPhotoButton:
            imagePicker?.present(from: addPhotoButton)
        case cancelButton:
            input.send(.cancel)
            dismiss(animated: true)
        case saveButton:
            prepareUser()
            input.send(.save(user: user))
        default:
            break
        }
    }
    
    func setup(with user: User) {
        self.profileEditor.set(name: user.name, bio: user.bio)
        self.profileImageView.setName(name: user.name)
        
        guard let avatar = user.avatar, let profileImage = UIImage(data: avatar) else { return }
        self.profileImageView.setImage(image: profileImage)
    }
    
    func savingInProgress() {
        activity.startAnimating()
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: activity), animated: true)
        
        UIView.animate(withDuration: 0.3) {
            [self.addPhotoButton, self.profileEditor].forEach {
                $0.alpha = 0.5
                $0.isUserInteractionEnabled = false
            }
        }
    }
    
    func savingCanceled() {
        activity.stopAnimating()
        self.navigationItem.setRightBarButton(saveButton, animated: true)
        
        UIView.animate(withDuration: 0.3) {
            [self.addPhotoButton, self.profileEditor].forEach {
                $0.alpha = 1
                $0.isUserInteractionEnabled = true
            }
        }
    }
    
    func prepareUser() {
        guard let name = profileEditor.enteredName(),
              let bio = profileEditor.enteredBio()
        else { return }
        
        self.user.name      = name
        self.user.bio       = bio
        self.user.avatar    = profileImageView.image?.pngData()
    }
}

// MARK: - Методы конфигурации

private extension ProfileEditorVC {
    func bindViewModel() {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        output.sink { [weak self] event in
            switch event {
            case .savingSucceed:
                self?.savingCanceled()
            case .savingInProgress:
                self?.savingInProgress()
            case .savingCanceled:
                self?.savingCanceled()
            case .showAlert(let alert):
                self?.present(alert, animated: true)
            }
        }.store(in: &disposeBag)
    }
    
    func configure() {
        self.view.backgroundColor = .secondarySystemBackground
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    func configureNavigationBar() {
        self.navigationItem.title = Project.Title.editProfile
        
        cancelButton = UIBarButtonItem(title: Project.Button.cancel,
                                       style: .plain,
                                       target: self,
                                       action: #selector(buttonTapped))
        
        saveButton = UIBarButtonItem(title: Project.Button.save,
                                       style: .plain,
                                       target: self,
                                       action: #selector(buttonTapped))
        
        self.navigationItem.setLeftBarButton(cancelButton, animated: false)
        self.navigationItem.setRightBarButton(saveButton, animated: false)
    }
    
    func configureStackView() {
        self.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis      = .vertical
        stackView.spacing   = 24
        stackView.alignment = .center
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func configureProfileImageView() {
        self.stackView.addArrangedSubview(profileImageView)
    }
    
    func configureAddPhotoButton() {
        self.stackView.addArrangedSubview(addPhotoButton)
        
        self.addPhotoButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        self.addPhotoButton.configure(title: Project.Button.addPhoto, fontSize: 16,
                                      fontWeight: .regular, titleColor: .systemBlue)
    }
    
    func configureProfileEditor() {
        self.stackView.addArrangedSubview(profileEditor)
        profileEditor.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
    }
    
    func configureImagePicker() {
        self.imagePicker = TCImagePicker(presentationController: self, delegate: self)
    }
}

// MARK: - ImagePickerProtocol

extension ProfileEditorVC: ImagePickerProtocol {
    func didSelect(image: UIImage?) {
        guard let image else { return }
        self.profileImageView.setImage(image: image)
    }
}
