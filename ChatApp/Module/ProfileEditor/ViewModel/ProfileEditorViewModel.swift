//
//  ProfileEditorViewModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 18.04.2023.
//

import UIKit
import Combine

final class ProfileEditorViewModel {
    // MARK: - Сервисы
    
    private var fileService: FileServiceProtocol
    
    // MARK: - Параметры
    
    private var user: User = .defaultUser
    
    // MARK: - Combine
    
    private var output      = PassthroughSubject<Output, Never>()
    private var disposeBag  = Set<AnyCancellable>()
    
    // MARK: - Многопоточность
    
    private var userWorkItem: DispatchWorkItem?
    private var backgroundQueue: DispatchQueue? = DispatchQueue(label: "user.queue", qos: .utility)
    
    // MARK: - Инициализация
    
    init(fileService: FileServiceProtocol = FileService.shared) {
        self.fileService = fileService
    }
}

// MARK: - ViewModel

extension ProfileEditorViewModel: ViewModel {
    enum Input {
        case save(user: User)
        case cancel
    }
    
    enum Output {
        case savingSucceeded
        case savingInProgress
        case savingCanceled
        case showAlert(alert: UIAlertController)
    }
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .save(let user):
                self?.startSaving(for: user)
            case .cancel:
                self?.cancelSaving()
                self?.output.send(.savingCanceled)
            }
        }.store(in: &disposeBag)
        
        return output.eraseToAnyPublisher()
    }
}

// MARK: - Сохранение пользователя

private extension ProfileEditorViewModel {
    func startSaving(for user: User) {
        output.send(.savingInProgress)
        userWorkItem = DispatchWorkItem(block: { [weak self] in
            sleep(1)
            guard let isCancelled = self?.userWorkItem?.isCancelled, !isCancelled else { return }
            self?.save(user: user)
        })
        
        guard let userWorkItem else { return }
        backgroundQueue?.async(execute: userWorkItem)
    }
    
    func save(user: User) {
        do {
            try fileService.save(user: user)
            // Отключение режима редактирования
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                // Показ уведомления об успешном сохранении
                self.makeAlert(title: Project.AlertTitle.success, message: Project.AlertTitle.successMesssage, style: .alert) {
                    let ok = UIAlertAction(title: Project.Button.ok, style: .cancel)
                    return [ok]
                }
                self.output.send(.savingSucceeded)
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                // Показ уведомления об ошибке при сохранении
                self.makeAlert(title: Project.AlertTitle.failure, message: Project.AlertTitle.failureMessage, style: .alert) {
                    let ok = UIAlertAction(title: Project.Button.ok, style: .cancel) { _ in
                        self.output.send(.savingCanceled)
                    }
                    let tryAgain = UIAlertAction(title: Project.Button.tryAgain, style: .default) { _ in
                        self.startSaving(for: user)
                    }
                    return [ok, tryAgain]
                }
            }
        }
    }
}

// MARK: - Отмена сохранения

private extension ProfileEditorViewModel {
    func cancelSaving() {
        user = fileService.currentUser
        userWorkItem?.cancel()
        userWorkItem = nil
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.output.send(.savingCanceled)
        }
    }
}

// MARK: - Вспомогательные методы

private extension ProfileEditorViewModel {
    /// Показ уведомления
    /// - Parameters:
    ///   - title: Заголовок уведомления
    ///   - message: Сообщение уведомления
    ///   - style: Стиль уведомления
    ///   - actions: Замыкание для передачи кнопок действия в уведомление
    func makeAlert(title: String?, message: String?, style: UIAlertController.Style, actions: () -> [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        actions().forEach { action in
            alertController.addAction(action)
        }
        
        output.send(.showAlert(alert: alertController))
    }
}
