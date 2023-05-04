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
    private var viewModel               = ProfileViewModel()
    private var input                   = PassthroughSubject<ProfileViewModel.Input, Never>()
    private var disposeBag              = Set<AnyCancellable>()
    private var cardTransitionService   = CardTransitionService()
    
    private let buttonPressRecognizer   = UILongPressGestureRecognizer()
    private var isAnimating             = false
    
    private let animatingLayer          = CAEmitterLayer()
    private let longPressRecognizer     = UILongPressGestureRecognizer()
    
    // MARK: - UI
    
    private var stackView               = UIStackView()
    private let profileImageView        = TCProfileImageView(size: .large)
    private var addPhotoButton          = UIButton()
    private var nameLabel               = UILabel()
    private var bioLabel                = UILabel()
    private var editButton              = UIButton()
    private var imagePickerController   = UIImagePickerController()
}

// MARK: - Жизненный цикл

extension ProfileVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        configure()
        configureAnimationLayer()
        configureLongPressRecognizer()
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
            self.showActionSheet()
        case editButton:
            self.input.send(.showEditor)
        default:
            break
        }
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takeAPhoto = UIAlertAction(title: Project.Button.takePhoto, style: .default) { [weak self] _ in
            guard let self else { return }
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true)
        }
        let selectFromGalleryAction = UIAlertAction(title: Project.Button.selectFromGallery, style: .default) { [weak self] _ in
            guard let self else { return }
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
        }
        let loadImageAction = UIAlertAction(title: Project.Button.download, style: .default) { [weak self] _ in
            guard let self else { return }
            let imageLoaderVC = ListLoadImagesVC()
            let navigationController = UINavigationController(rootViewController: imageLoaderVC)
            imageLoaderVC.imagePickerSubject
                .sink { (image, _) in
                    self.input.send(.imageDidSelect(image: image))
                }.store(in: &self.disposeBag)
            self.present(navigationController, animated: true)
        }
        let cancelAction = UIAlertAction(title: Project.Button.cancel, style: .cancel)
        
        actionSheet.addAction(takeAPhoto)
        actionSheet.addAction(selectFromGalleryAction)
        actionSheet.addAction(loadImageAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true)
    }
    
    @objc
    func editButtonLongPressed() {
        guard buttonPressRecognizer.state == .began else { return }
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
            self.editButton.layer.removeAllAnimations()
            self.editButton.layoutIfNeeded()
        }
    }
    
    @objc
    func viewLongPressed() {
        let location = longPressRecognizer.location(in: view)
        
        animatingLayer.emitterPosition = location
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
    
    func configureAnimationLayer() {
        animatingLayer.emitterPosition = view.frame.origin
        animatingLayer.emitterSize = CGSize(width: 30, height: 30)
        animatingLayer.emitterShape = CAEmitterLayerEmitterShape.circle
        
        let cell = CAEmitterCell()
        cell.contents = UIImage(named: "TinkoffGerb")
        cell.lifetime = 1
        animatingLayer.emitterCells = [cell]
        
        view.layer.addSublayer(animatingLayer)
    }
    
    func configureLongPressRecognizer() {
        longPressRecognizer.delegate = self
        longPressRecognizer.cancelsTouchesInView = false
        longPressRecognizer.minimumPressDuration = 0.1
        longPressRecognizer.addTarget(self, action: #selector(viewLongPressed))
        
        view.addGestureRecognizer(longPressRecognizer)
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
            .translatesAutoresizingMaskIntoConstraints(false)
            .addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            .build()
        
        buttonPressRecognizer.addTarget(self, action: #selector(editButtonLongPressed))
        self.editButton.addGestureRecognizer(buttonPressRecognizer)
        self.stackView.addArrangedSubview(editButton)
        
        NSLayoutConstraint.activate([
            editButton.heightAnchor.constraint(equalToConstant: 50),
            editButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -40)
        ])
    }
    
    func configureImagePicker() {
        imagePickerController.delegate         = self
        imagePickerController.allowsEditing    = true
//        self.imagePicker = TCImagePicker(presentationController: self, delegate: self)
    }
}

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.input.send(.imageDidSelect(image: image))
        } else if let image = info[.originalImage] as? UIImage {
            self.input.send(.imageDidSelect(image: image))
        }
        
        dismiss(animated: true)
    }
}

extension ProfileVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
