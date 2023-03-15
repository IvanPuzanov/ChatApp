//
//  Presenter.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 09.03.2023.
//

import Foundation

protocol AnyPresenter {
    associatedtype PresenterType
    func setDelegate(_ delegate: PresenterType)
}
