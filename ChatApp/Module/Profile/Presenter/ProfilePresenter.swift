//
//  ProfilePresenter.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    func userDidFetch(_ userProfile: UserProfile)
}

final class ProfilePresenter {
    // MARK: - Параметры
    typealias ProfilePresenterView = ProfilePresenterProtocol & ProfileVC
    private weak var view: ProfilePresenterView?
    
    // MARK: - Параметры состояния
    private var isSaving: Bool = false
    
    // MARK: - Компоненты
    private let imagePicker = UIImagePickerController()
    private var persistenceService: PersistenceProtocol?
}

// MARK: - Методы событий
extension ProfilePresenter: AnyPresenter {
    typealias PresenterType = ProfilePresenterView
    func setDelegate(_ view: ProfilePresenterView) {
        self.view = view
    }
    
    func fetchUserProfile() {
        view?.userDidFetch(UserProfile.fetchUserProfile())
    }
    
    // MARK: - Сохранение/чтение данных
    enum SaveType { case gcd, operation }
    func save(with type: SaveType, name: String?, bio: String?, image: UIImage?) {
        DispatchQueue.main.async {
            self.savingInProgress()
        }
        
        switch type {
        case .gcd:
            persistenceService = GCDService()
        case .operation:
            persistenceService = OperationService()
        }
        
        guard let persistenceService else { return }
        persistenceService.save { result in
            switch result {
            case .success:
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.disableEditing()
                    self.showAlert(title: "Success🥳", message: "You are breathtaking", style: .alert) {
                        let ok = AlertActionButton.ok
                        return [ok]
                    }
                }
            case .failure:
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.disableEditing()
                    self.showAlert(title: "Something went worng😢", message: "Could not save profile", style: .alert) {
                        let ok = AlertActionButton.ok
                        let tryAgain = UIAlertAction(title: "Try again", style: .default) { _ in
                            self.enableEditing()
                            self.save(with: type, name: name, bio: bio, image: image)
                        }
                        return [ok, tryAgain]
                    }
                }
            }
        }
    }
    
    func read() {
        
    }
    
    func cancelSaving() {
        guard let persistenceService else { return }
        persistenceService.cancel()
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.disableEditing()
        }
    }
}

// MARK: - Методы режима редактирования
extension ProfilePresenter {
    func enableEditing() {
        guard let view else { return }
        
        view.navigationItem.setRightBarButton(view.saveButton, animated: true)
        view.navigationItem.setLeftBarButton(view.cancelButton, animated: true)
        view.profileEditor.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.2) {
            [view.profileNameLabel, view.bioMessageLabel].forEach {
                $0.alpha = 0
            }
        }
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
            [view.profileNameLabel, view.bioMessageLabel].forEach {
                $0.isHidden = true
            }
            
            [view.profileEditor].forEach {
                $0.alpha = 1
                $0.isHidden = false
            }
            
            guard view.traitCollection.userInterfaceStyle != .dark else { return }
            view.view.backgroundColor = .secondarySystemBackground
        }
    }
    
    func disableEditing() {
        guard let view else { return }
        view.activity.stopAnimating()
        view.profileEditor.resignFirstResponder()
        
        view.navigationItem.setLeftBarButton(view.closeButton, animated: true)
        view.navigationItem.setRightBarButton(view.editButton, animated: true)
        
        view.addPhotoButton.isUserInteractionEnabled = true
        view.profileEditor.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8) {
            [view.profileNameLabel, view.bioMessageLabel, view.addPhotoButton].forEach {
                $0.alpha = 1
                $0.isHidden = false
            }
            
            [view.profileEditor].forEach {
                $0.alpha = 0
                $0.isHidden = true
            }
        
            view.view.backgroundColor = .systemBackground
        }
    }
    
    func savingInProgress() {
        guard let view else { return }
        
        view.activity.startAnimating()
        view.navigationItem.setRightBarButton(.init(customView: view.activity), animated: true)
        
        view.profileEditor.isUserInteractionEnabled = false
        view.addPhotoButton.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3) {
            view.addPhotoButton.alpha   = 0.5
            view.profileEditor.alpha    = 0.5
        }
    }
}

// MARK: -
private extension ProfilePresenter {
    enum AlertActionButton {
        static let ok = UIAlertAction(title: "Ok", style: .cancel)
    }
    func showAlert(title: String?, message: String?, style: UIAlertController.Style, actions: () -> [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        actions().forEach { action in
            alertController.addAction(action)
        }
        
        self.view?.present(alertController, animated: true)
    }
    
    func showActionSheetController() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction   = UIAlertAction(title: Project.Button.takePhoto, style: .default)
        let selectFromGallery = UIAlertAction(title: Project.Button.selectFromGallery, style: .default) { _ in
            self.view?.present(self.imagePicker, animated: true)
        }
        let cancel              = UIAlertAction(title: Project.Button.cancel, style: .cancel)
        
        alertController.addAction(takePhotoAction)
        alertController.addAction(selectFromGallery)
        alertController.addAction(cancel)
        
        self.view?.present(alertController, animated: true)
    }
}
