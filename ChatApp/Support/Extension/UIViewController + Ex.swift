//
//  UIViewController + Ex.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 04.04.2023.
//

import UIKit

extension UIViewController {
    func showErrorAlert(title: String, message: String?) {
        let alert   = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok      = UIAlertAction(title: Project.Button.ok, style: .cancel)
        
        alert.addAction(ok)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func showActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
    }
}
