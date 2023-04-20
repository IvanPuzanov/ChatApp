//
//  SettingsViewModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 19.04.2023.
//

import UIKit
import Combine

final class SettingsViewModel {
    private let output          = PassthroughSubject<Output, Never>()
    private var disposeBag      = Set<AnyCancellable>()
    private let persistenceService: UserDefaultsServiceProtocol = UserDefaultsService()
}

extension SettingsViewModel: ViewModel {
    enum Input {
        case save
    }
    
    enum Output {
        case saveSucceeced
    }
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .save:
                self?.save()
            }
        }.store(in: &disposeBag)
        
        return output.eraseToAnyPublisher()
    }
}

private extension SettingsViewModel {
    private func save() {
        switch UITraitCollection.current.userInterfaceStyle {
        case .dark:
            self.persistenceService.save(Theme.dark, forKey: .themeSettings)
        case .light:
            self.persistenceService.save(Theme.light, forKey: .themeSettings)
        default:
            break
        }
        
        output.send(.saveSucceeced)
    }
}
