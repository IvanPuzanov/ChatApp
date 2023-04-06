//
//  TCProfileImagePresenter.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 28.02.2023.
//

import UIKit

protocol TCProfileImagePresenterProtocol: AnyObject {
    func nameDidSet(name: String)
    func imageDidSet(image: UIImage)
}

final class TCProfileImagePresenter {
    private weak var view: TCProfileImagePresenterProtocol?
    
    private var name: String?
    private var image: UIImage?
    public var user: User? { didSet { setUser(user: self.user) } }
}

extension TCProfileImagePresenter {
    func setName(_ name: String) {
        let name = prepareName(name)
        validate()
    }
    
    func setImage(_ image: UIImage?) {
        self.image = image
        validate()
    }
    
    func validate() {
        switch (image, name) {
        case let (image, _):
            guard let image else { return }
            self.view?.imageDidSet(image: image)
        case (_, name):
            guard let name else { return }
            self.view?.nameDidSet(name: name)
        }
    }
    
    func setUser(user: User?) {
        guard let user else { return }
        guard let imageData = user.avatar, let image = UIImage(data: imageData) else {
            let preparedName = prepareName(user.name)
            self.view?.nameDidSet(name: preparedName)
            return
        }
        self.view?.imageDidSet(image: image)
    }
    
    func setDelegate(_ view: TCProfileImagePresenterProtocol) {
        self.view = view
    }
    
    private func prepareName(_ name: String) -> String {
        let splitedName = name.split(separator: " ")
        var preparedName = String()
        
        for word in splitedName {
            guard let firstChar = word.first, preparedName.count < 2 else { continue }
            preparedName.append(String(firstChar))
        }
        
        return preparedName.uppercased()
    }
}
