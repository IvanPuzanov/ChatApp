//
//  ProfileVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.02.2023.
//

import UIKit

final class ProfileVC: UIViewController {
    // MARK: - Parameters
    private let presenter = ProfilePresenter()
    
    // MARK: - Views
    private let stackView           = UIStackView()
    private var closeButton         = UIBarButtonItem()
    private var editButton          = UIBarButtonItem()
    private let profileImageView    = TCProfileImageView(size: .large)
    private let addPhotoButton      = UIButton()
    private let profileNameLabel    = UILabel()
    private let bioMessageLabel     = UILabel()
    private var imagePicker: TCImagePicker!
}

// MARK: - Lifecycle
extension ProfileVC {
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        
        // На данном этапе жизненного цикла subviews еще
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
        default:
            break
        }
    }
}

// MARK: - Configure methods
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
        
        editButton = UIBarButtonItem(title: Project.Button.edit, style: .plain, target: nil, action: nil)
        navigationItem.setRightBarButton(editButton, animated: true)
    }
    
    func configureStackView() {
        self.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.alignment = .center
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func configureProfileImageView() {
        self.stackView.addArrangedSubview(profileImageView)
    }
    
    func configureAddPhotoButton() {
        self.stackView.addArrangedSubview(addPhotoButton)
        self.stackView.setCustomSpacing(24, after: profileImageView)
        
        self.addPhotoButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        self.addPhotoButton.configure(title: Project.Button.addPhoto, fontSize: 16,
                                      fontWeight: .regular, titleColor: .systemBlue)
    }
    
    func configureProfileNameLabel() {
        self.stackView.addArrangedSubview(profileNameLabel)
        self.stackView.setCustomSpacing(24, after: addPhotoButton)
        
        self.profileNameLabel.configure(fontSize: 22, fontWeight: .bold, textColor: .label)
    }
    
    func configureBioMessageLabel() {
        self.stackView.addArrangedSubview(bioMessageLabel)
        self.stackView.setCustomSpacing(10, after: profileNameLabel)
        
        self.bioMessageLabel.configure(fontSize: 17, fontWeight: .regular, textColor: .secondaryLabel)
        self.bioMessageLabel.numberOfLines = 3
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
