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
    typealias ProfilePresenterView = ProfilePresenterProtocol & UIViewController
    private weak var view: ProfilePresenterView?
    
    // MARK: -
    private let imagePicker = UIImagePickerController()
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
    
    func showActionSheetController() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction   = UIAlertAction(title: Project.Button.takePhoto, style: .default)
        let selectFromGallery = UIAlertAction(title: Project.Button.selectFromGallery, style: .default) { _ in
            self.view?.present(self.imagePicker, animated: true)
        }
        let cancel              = UIAlertAction(title: Project.Button.cancel, style: .cancel)
        
        alertController.addAction(takePhotoAction)
        alertController.addAction(selectFromGallery)
        alertController.addAction(cancel)
        
        self.view?.present(alertController, animated: true)
    }
    
    enum SaveType {
        case gcd, operation
    }
    func save(with type: SaveType, name: String?, bio: String?, image: UIImage?) {
        
    }
}
