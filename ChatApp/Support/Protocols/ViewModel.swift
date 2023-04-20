//
//  ViewModel.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 20.04.2023.
//

import Combine

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}
