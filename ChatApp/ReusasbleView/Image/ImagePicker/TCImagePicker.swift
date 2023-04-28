//
//  TCImagePicker.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 27.02.2023.
//

import UIKit

protocol ImagePickerProtocol: AnyObject {
    func didSelect(image: UIImage?)
}

final class TCImagePicker: NSObject {
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerProtocol?
    
    public init(presentationController: UIViewController, delegate: ImagePickerProtocol) {
        self.pickerController       = UIImagePickerController()
        super.init()
        self.presentationController = presentationController
        self.delegate               = delegate
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
    }
}

private extension TCImagePicker {
    func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else { return nil }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image: image)
    }
}

extension TCImagePicker {
    func present(from sourceView: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: Project.Button.takePhoto) {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .photoLibrary, title: Project.Button.selectFromGallery) {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .photoLibrary, title: Project.Button.selectFromGallery) {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: Project.Button.cancel, style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
}

extension TCImagePicker: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        
        self.pickerController(picker, didSelect: image)
    }
}

extension TCImagePicker: UINavigationControllerDelegate {}
