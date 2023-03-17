//
//  ProfileVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.02.2023.
//

import UIKit

final class ProfileVC: UIViewController {
    // MARK: - Параметры
    private let presenter = ProfilePresenter()
    
    // MARK: - UI
    private let stackView           = UIStackView()
    
    private var closeButton         = UIBarButtonItem()
    private var editButton          = UIBarButtonItem()
    private var cancelButton        = UIBarButtonItem()
    private var saveButton          = UIBarButtonItem()
    
    private let profileImageView    = TCProfileImageView(size: .large)
    private let addPhotoButton      = UIButton()
    private let profileNameLabel    = UILabel()
    private let bioMessageLabel     = UILabel()
    private let profileEditor       = TCProfileEditor()
    
    private var imagePicker: TCImagePicker!
}

// MARK: - Жизненный цикл
extension ProfileVC {
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        
        // На данном этапе жизненного цикла subUI еще
        // НЕ РАСПОЛОЖЕНЫ, и поэтому их frame неизвестен
        print("Frame: \(addPhotoButton.frame), \(#function)")
    }
    
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
        
        presenter.fetchUserProfile()
    }
}

// MARK: -
private extension ProfileVC {
    @objc
    func buttonTapped(_ button: UIControl) {
        switch button {
        case closeButton:
            self.dismiss(animated: true)
        case addPhotoButton:
            imagePicker.present(from: addPhotoButton)
        case editButton:
            navigationItem.setRightBarButton(saveButton, animated: true)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8) {
                [self.profileNameLabel, self.bioMessageLabel].forEach {
                    $0.alpha = 0
                    $0.isHidden = true
                }
                
                [self.profileEditor].forEach {
                    $0.alpha = 1
                    $0.isHidden = false
                }
    
                self.view.backgroundColor = .secondarySystemBackground
            }
            
            navigationItem.setLeftBarButton(cancelButton, animated: true)
        case cancelButton:
            navigationItem.setLeftBarButton(closeButton, animated: true)
            navigationItem.setRightBarButton(editButton, animated: true)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8) {
                [self.profileNameLabel, self.bioMessageLabel].forEach {
                    $0.alpha = 1
                    $0.isHidden = false
                }
                
                [self.profileEditor].forEach {
                    $0.alpha = 0
                    $0.isHidden = true
                }
            
                self.view.backgroundColor = .systemBackground
            }
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
        
        var saveGCD = UIAction(title: "Save GCD") { _ in
            self.presenter.save(with: .gcd, name: nil, bio: nil, image: nil)
        }
        var saveOperation = UIAction(title: "Save Operation") { _ in
            self.presenter.save(with: .operation, name: nil, bio: nil, image: nil)
        }
        saveButton = UIBarButtonItem(image: .init(systemName: "ellipsis.circle"), menu: UIMenu(children: [saveGCD, saveOperation]))
        
    }
    
    func configureStackView() {
        self.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 24
        
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

// MARK: -
extension ProfileVC: ImagePickerProtocol {
    func didSelect(image: UIImage?) {
        self.profileImageView.setImage(image)
    }
}

// MARK: -
extension ProfileVC: ProfilePresenterProtocol {
    func userDidFetch(_ userProfile: UserProfile) {
        self.profileNameLabel.text = userProfile.name
        self.bioMessageLabel.text = userProfile.description
        self.profileImageView.setName(userProfile.name)
        self.profileImageView.setImage(userProfile.avatar)
    }
}
