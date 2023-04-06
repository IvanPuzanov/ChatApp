//
//  ProfileViewModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.04.2023.
//

import Combine

final class ProfileViewModel {
    // MARK: - Параметры
    
    private var fileService     = FileService.shared
    private var output          = PassthroughSubject<Output, Never>()
    private var cancellabels    = Set<AnyCancellable>()
    private var user: User      = .defaultUser
}

extension ProfileViewModel: ViewModel {
    enum Input {
        case fetchUser
    }
    
    enum Output {
        case userDidFetch(user: User)
    }
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        return output.eraseToAnyPublisher()
    }
}

private extension ProfileViewModel {
    
}
