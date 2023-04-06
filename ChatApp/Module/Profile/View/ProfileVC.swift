//
//  ProfileVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.02.2023.
//

import UIKit
import Combine

final class ProfileVC: UIViewController {
    // MARK: - Параметры
    
    private let presenter = ProfilePresenter()
    
    // MARK: - UI
    
    public let stackView          = UIStackView()
    
    public var closeButton        = UIBarButtonItem()
    public var editButton         = UIBarButtonItem()
    public var cancelButton       = UIBarButtonItem()
    public var saveButton         = UIBarButtonItem()
    public var activity           = UIActivityIndicatorView(style: .medium)
    
    public let profileImageView   = TCImageView(size: .large)
    public let addPhotoButton     = UIButton()
    public let profileNameLabel   = UILabel()
    public let bioMessageLabel    = UILabel()
    public let profileEditor      = TCProfileEditor()
    
    private var imagePicker: TCImagePicker!
}

// MARK: - Жизненный цикл

extension ProfileVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindToPresenter()
        
        configure()
        configureNavigationBar()
        configureStackView()
        configureProfileImageView()
        configureAddPhotoButton()
        configureProfileNameLabel()
        configureBioMessageLabel()
        configureProfileEditor()
        configureImagePicker()
        
        presenter.createSubscriptions()
        presenter.fetchUser()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        presenter.cancelSaving()
        presenter.removeSubscriptions()
    }
}

// MARK: - Методы обработки событий

private extension ProfileVC {
    @objc
    func buttonTapped(_ button: UIControl) {
        switch button {
        case closeButton:
            self.dismiss(animated: true)
        case addPhotoButton:
            imagePicker.present(from: addPhotoButton)
        case editButton:
            presenter.enableEditing()
        case cancelButton:
            presenter.cancelSaving()
        case saveButton:
            presenter.saveUser()
        default:
            break
        }
    }
}

// MARK: - Методы конфигурации

private extension ProfileVC {
    func bindToPresenter() {
        self.presenter.setDelegate(self)
    }
    
    func configure() {
        self.view.backgroundColor = .systemBackground
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    func configureNavigationBar() {
        self.navigationItem.title = Project.Title.myProfile
        
        closeButton = UIBarButtonItem(title: Project.Button.close,
                                      style: .plain,
                                      target: self,
                                      action: #selector(buttonTapped))
        navigationItem.setLeftBarButton(closeButton, animated: true)
        
        editButton = UIBarButtonItem(title: Project.Button.edit,
                                     style: .plain,
                                     target: self,
                                     action: #selector(buttonTapped))
        navigationItem.setRightBarButton(editButton, animated: true)
        
        cancelButton = UIBarButtonItem(title: Project.Button.cancel,
                                       style: .plain,
                                       target: self,
                                       action: #selector(buttonTapped))
        
        saveButton = UIBarButtonItem(title: Project.Button.save,
                                       style: .plain,
                                       target: self,
                                       action: #selector(buttonTapped))
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
    
    func configureProfileNameLabel() {
        self.stackView.addArrangedSubview(profileNameLabel)
        
        profileNameLabel.preferredMaxLayoutWidth = 250
        self.profileNameLabel.configure(fontSize: 22, fontWeight: .bold, textColor: .label)
    }
    
    func configureBioMessageLabel() {
        self.stackView.addArrangedSubview(bioMessageLabel)
        self.stackView.setCustomSpacing(10, after: profileNameLabel)
        
        self.bioMessageLabel.preferredMaxLayoutWidth = 250
        self.bioMessageLabel.configure(fontSize: 17, fontWeight: .regular, textColor: .secondaryLabel)
        self.bioMessageLabel.numberOfLines = 3
    }
    
    func configureProfileEditor() {
        self.stackView.addArrangedSubview(profileEditor)
        profileEditor.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        profileEditor.isHidden = true
    }
    
    func configureImagePicker() {
        self.imagePicker = TCImagePicker(presentationController: self, delegate: self)
    }
}

// MARK: - ImagePickerProtocol

extension ProfileVC: ImagePickerProtocol {
    func didSelect(image: UIImage?) {
        guard let image else { return }
        self.profileImageView.setImage(image: image)
        self.presenter.enableEditing()
    }
}

// MARK: - ProfilePresenterProtocol

extension ProfileVC: ProfilePresenterProtocol {}
