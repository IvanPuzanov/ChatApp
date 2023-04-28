//
//  UIImageView + Ex.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 24.04.2023.
//

import UIKit

extension UIImageView {
    func loadImage(for url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
