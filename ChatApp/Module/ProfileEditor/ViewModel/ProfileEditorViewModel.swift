//
//  ProfileEditorViewModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 05.04.2023.
//

import Combine

final class ProfileEditorViewModel {
    // MARK: - Параметры
    
    private var output = PassthroughSubject<Output, Never>()
}

extension ProfileEditorViewModel: ViewModel {
    enum Input {
        
    }
    
    enum Output {
        
    }
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        return output.eraseToAnyPublisher()
    }
}
