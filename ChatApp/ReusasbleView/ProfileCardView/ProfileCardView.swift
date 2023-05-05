//
//  ProfileCardView.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 01.05.2023.
//

import UIKit

final class ProfileCardView: UIView {
    // MARK: - Параметры
    
    enum CardViewMode {
        case card
        case full
    }
    private var cardViewMode: CardViewMode
    private var gestureRecognizer = UILongPressGestureRecognizer()
    private var isAnimating: Bool = false
    
    // MARK: - UI
    
    private var stackView               = UIStackView()
    private let profileImageView        = TCProfileImageView(size: .large)
    private var addPhotoButton          = UIButton()
    private var nameLabel               = UILabel()
    private var bioLabel                = UILabel()
    private var editButton              = UIButton()
    private var imagePickerController   = UIImagePickerController()
    
    // MARK: - Инициализация
    
    init(cardViewMode: CardViewMode) {
        self.cardViewMode = cardViewMode
        super.init(frame: .zero)
        
        configure()
        configureStackView()
        configureProfileImageView()
        configureAddPhotoButton()
        configureNameLabel()
        configureBioLabel()
        configureEditButton()
        configureImagePicker()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Методы обработки событий

extension ProfileCardView {
    func setup(with user: User) {
        self.nameLabel.text = user.name
        self.bioLabel.text  = user.bio
        self.profileImageView.setName(name: user.name)
        
        guard let avatar = user.avatar, let profileImage = UIImage(data: avatar) else { return }
        self.profileImageView.setImage(image: profileImage)
    }
    
    func addEditButtonAction(target: Any?, action: Selector) {
        self.editButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    @objc
    func changeAnimation() {
        guard gestureRecognizer.state == .began else { return }
        isAnimating.toggle()
        
        if isAnimating {
            let angle: CGFloat  = 18 * (Double.pi / 180)
            
            let position        = CABasicAnimation(keyPath: #keyPath(CALayer.position))
            position.fromValue  = CGPoint(x: editButton.center.x - 10, y: editButton.center.y - 10)
            position.toValue    = CGPoint(x: editButton.center.x + 10, y: editButton.center.y + 10)
            
            let rotation        = CABasicAnimation(keyPath: "transform.rotation")
            rotation.fromValue  = -angle
            rotation.toValue    = angle
            
            let groupAnimation          = CAAnimationGroup()
            groupAnimation.animations   = [position, rotation]
            groupAnimation.duration     = 0.3
            groupAnimation.repeatCount  = .infinity
            groupAnimation.autoreverses = true
            
            editButton.layer.add(groupAnimation, forKey: nil)
        } else {
            editButton.layer.removeAllAnimations()
        }
    }
}

// MARK: - Методы конфигурации

private extension ProfileCardView {
    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
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
        
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
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
//            .addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
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
            .translatesAutoresizingMaskIntoConstraints(false)
            .build()
        
        gestureRecognizer.addTarget(self, action: #selector(changeAnimation))
        editButton.addGestureRecognizer(gestureRecognizer)
        
        self.stackView.addArrangedSubview(editButton)
        
        NSLayoutConstraint.activate([
            editButton.heightAnchor.constraint(equalToConstant: 50),
            editButton.widthAnchor.constraint(equalTo: widthAnchor, constant: -60)
        ])
    }
    
    func configureImagePicker() {
        imagePickerController.delegate         = self
        imagePickerController.allowsEditing    = true
    }
}

extension ProfileCardView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage {
//            self.input.send(.imageDidSelect(image: image))
        } else if let image = info[.originalImage] as? UIImage {
//            self.input.send(.imageDidSelect(image: image))
        }
        
//        dismiss(animated: true)
    }
}
