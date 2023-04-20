//
//  ProfileViewModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.04.2023.
//

import UIKit
import Combine

final class ProfileViewModel {
    // MARK: - Сервисы
    
    private var fileService: FileServiceProtocol
    
    // MARK: - Combine
    
    private var output          = PassthroughSubject<Output, Never>()
    private var disposeBag      = Set<AnyCancellable>()
    
    // MARK: - Параметры
    
    private var user: User = .defaultUser
    
    // MARK: - Инициализация
    
    init(fileService: FileServiceProtocol = FileService.shared) {
        self.fileService = fileService
        bindToFileService()
    }
}

// MARK: - ViewModel

extension ProfileViewModel: ViewModel {
    enum Input {
        case fetchUser
        case imageDidSelect(image: UIImage)
        case showEditor
    }
    
    enum Output {
        case userDidFetch(user: User)
        case showEditor(with: User)
    }
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .fetchUser:
                self?.fetchUser()
            case .imageDidSelect(let image):
                self?.setImageToUser(image)
                
                guard let user = self?.user else { return }
                self?.output.send(.showEditor(with: user))
            case .showEditor:
                guard let user = self?.user else { return }
                self?.output.send(.showEditor(with: user))
            }
        }.store(in: &disposeBag)
        
        return output.eraseToAnyPublisher()
    }
}

private extension ProfileViewModel {
    func fetchUser() {
        fileService.fetchUser()
        output.send(.userDidFetch(user: user))
    }
    
    func bindToFileService() {
        fileService
            .userPublisher
            .decode(type: User.self, decoder: JSONDecoder())
            .sink { _ in
                return
            } receiveValue: { [weak self] user in
                self?.user = user
                self?.output.send(.userDidFetch(user: user))
            }.store(in: &disposeBag)
    }
    
    func setImageToUser(_ image: UIImage) {
        self.user.avatar = image.pngData()
    }
}
