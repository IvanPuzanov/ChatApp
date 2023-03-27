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
    
    // MARK: - Компоненты
    private var concurrentService: ConcurrentServiceProtocol?
    private weak var fileService = FileService.shared
    private var userProfile: User?
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
    func save(with type: SaveType) {
        // Установка сервиса
        switch type {
        case .gcd:
            self.concurrentService = GCDService()
        case .operation:
            self.concurrentService = OperationService()
        }
        
        // Создание модели пользователя
        guard let userName = view?.profileEditor.enteredName(), !userName.isEmpty,
              let userBio  = view?.profileEditor.enteredBio()
        else {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.showAlert(title: Project.AlertTitle.ooops, message: Project.AlertTitle.noNameMessage, style: .alert) {
                    let ok = UIAlertAction(title: Project.Button.ok, style: .cancel)
                    return [ok]
                }
            }
            return
        }
        let user = User(name: userName, bio: userBio, avatar: view?.profileImageView.image?.pngData())
        
        // Начало процесса сохранения
        guard let concurrentService else { return }
        DispatchQueue.main.async {
            self.savingInProgress()
        }
        
        concurrentService.save(user: user) { [weak self] result in
            guard let self else { return }
            switch result {
                // Успешное сохранение
            case .success(let userResult):
                DispatchQueue.main.async {
                    // Отключение режима редактирования
                    self.disableEditing()
                    // Показ уведомления об успешном сохранении
                    self.showAlert(title: Project.AlertTitle.success, message: Project.AlertTitle.successMesssage, style: .alert) {
                        let ok = UIAlertAction(title: Project.Button.ok, style: .cancel)
                        return [ok]
                    }
                    self.set(with: userResult)
                }
                // Ошибка при сохранении
            case .failure:
                DispatchQueue.main.async {
                    // Отключение режима редактирования
                    self.disableEditing()
                    // Показ уведомления об ошибке при сохранении
                    self.showAlert(title: Project.AlertTitle.failure, message: Project.AlertTitle.failureMessage, style: .alert) {
                        let ok = UIAlertAction(title: Project.Button.ok, style: .cancel) { _ in
                            self.cancelSaving()
                        }
                        let tryAgain = UIAlertAction(title: Project.Button.tryAgain, style: .default) { _ in
                            self.enableEditing()
                            self.save(with: type)
                        }
                        return [ok, tryAgain]
                    }
                }
            }
        }
    }
    
    func fetchUser() {
        let user = fileService?.fetchUserProfile()
        self.userProfile = user
        set(with: user)
    }
    
    func cancelSaving() {
        set(with: fileService?.currentUser)
        
        guard let concurrentService else { return }
        concurrentService.cancel()
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.disableEditing()
        }
    }
}

// MARK: - Методы режима редактирования
extension ProfilePresenter {
    /// Включение режима редактирования
    func enableEditing() {
        guard let view else { return }
        
        view.navigationItem.setRightBarButton(view.saveButton, animated: true)
        view.navigationItem.setLeftBarButton(view.cancelButton, animated: true)
        view.navigationItem.title = Project.Title.editProfile
        view.profileEditor.showKeyboard(true)
        
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
            
            if UIScreen.main.bounds.height <= 667.0 {
                view.stackView.spacing = 5
            }
            
            guard view.traitCollection.userInterfaceStyle != .dark else { return }
            view.view.backgroundColor = .secondarySystemBackground
        }
    }
    
    /// Выключение режима редактирования
    func disableEditing() {
        guard let view else { return }
        view.activity.stopAnimating()
        view.profileEditor.showKeyboard(false)
        
        view.navigationItem.setLeftBarButton(view.closeButton, animated: true)
        view.navigationItem.setRightBarButton(view.editButton, animated: true)
        view.navigationItem.title = Project.Title.myProfile
        
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
            view.stackView.spacing = 24
        }
    }
    
    /// Показ анимации во время сохранения
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
    /// Показ уведомления
    /// - Parameters:
    ///   - title: Заголовок уведомления
    ///   - message: Сообщение уведомления
    ///   - style: Стиль уведомления
    ///   - actions: Замыкание для передачи кнопок действия в уведомление
    func showAlert(title: String?, message: String?, style: UIAlertController.Style, actions: () -> [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        actions().forEach { action in
            alertController.addAction(action)
        }
        
        self.view?.present(alertController, animated: true)
    }
    
    /// Установка значений профиля
    /// - Parameter user: Модель пользователя
    func set(with user: User?) {
        guard let user else { return }
        
        self.view?.profileNameLabel.text = user.name
        self.view?.bioMessageLabel.text = user.bio
        self.view?.profileEditor.set(name: user.name, bio: user.bio)
        self.view?.profileImageView.setName(user.name)
        
        guard let avatar = user.avatar else {
            self.view?.profileImageView.resetImage()
            return
        }
        self.view?.profileImageView.setImage(UIImage(data: avatar))
    }
}
