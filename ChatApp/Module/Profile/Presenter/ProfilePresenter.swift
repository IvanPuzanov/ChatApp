//
//  ProfilePresenter.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import Combine
import UIKit

protocol ProfilePresenterProtocol: AnyObject {}

final class ProfilePresenter {
    // MARK: - Параметры
    typealias ProfilePresenterView = ProfilePresenterProtocol & ProfileVC
    private weak var view: ProfilePresenterView?
    
    // MARK: - Компоненты
    private var concurrentService: ConcurrentServiceProtocol?
    private weak var fileService = _FileService.shared
    private var userProfile: User = .defaultUser {
        didSet { set(with: userProfile) }
    }
    
    // MARK: - Подписки
    private weak var userRequest: AnyCancellable?
}

// MARK: - Методы событий
extension ProfilePresenter: AnyPresenter {
    typealias PresenterType = ProfilePresenterView
    func setDelegate(_ view: ProfilePresenterView) {
        self.view = view
    }
    
    // MARK: - Сохранение/чтение данных
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
                view.stackView.spacing = 24
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
        self.view?.profileImageView.presenter.user = user
    }
}

// MARK: - Combine saving
extension ProfilePresenter {
    func createSubscriptions() {
        userRequest = fileService?
            .userPublisher
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .decode(type: User.self, decoder: JSONDecoder())
            .catch({ _ in Just(User.defaultUser) })
            .assign(to: \.userProfile, on: self)
    }
    
    func removeSubscriptions() {
        userRequest?.cancel()
        userRequest = nil
    }
    
    func fetchUser() {
        do {
            try fileService?.fetchUser()
        } catch {}
    }
    
    func save() {
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
        do {
            try fileService?.save(user: user)
            // Отключение режима редактирования
            self.disableEditing()
            // Показ уведомления об успешном сохранении
            self.showAlert(title: Project.AlertTitle.success, message: Project.AlertTitle.successMesssage, style: .alert) {
                let ok = UIAlertAction(title: Project.Button.ok, style: .cancel)
                return [ok]
            }
        } catch {
            self.disableEditing()
            // Показ уведомления об ошибке при сохранении
            self.showAlert(title: Project.AlertTitle.failure, message: Project.AlertTitle.failureMessage, style: .alert) {
                let ok = UIAlertAction(title: Project.Button.ok, style: .cancel) { _ in
                    self.cancelSaving()
                }
                let tryAgain = UIAlertAction(title: Project.Button.tryAgain, style: .default) { _ in
                    self.enableEditing()
                    self.save()
                }
                return [ok, tryAgain]
            }
        }
    }
}
