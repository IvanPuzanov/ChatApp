//
//  TCImageView.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 24.04.2023.
//

import UIKit

final class TCImageView: UIImageView {
    // MARK: - Очереди
    
    private var loadWorkItem: DispatchWorkItem?
    private var backgroundQueue = DispatchQueue(label: "imageLoadQueue", qos: .utility)
    
    convenience init() {
        self.init(frame: .zero)
        
        configure()
    }
}

extension TCImageView {
    func loadImage(urlString: String?) {
        guard let urlString else { return }
        guard let url = URL(string: urlString) else { return }
        
        loadImage(url: url)
    }
    
    func loadImage(url: URL) {
        makeLoadWorkItem(url: url)
        
        guard let loadWorkItem else { return }
        backgroundQueue.async(execute: loadWorkItem)
    }
    
    func cancelLoading() {
        image = nil
        
        loadWorkItem?.cancel()
        loadWorkItem = nil
        
    }
    
    private func makeLoadWorkItem(url: URL) {
        loadWorkItem = DispatchWorkItem { [weak self] in
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    guard let loadWorkItem = self?.loadWorkItem, !loadWorkItem.isCancelled else { return }
                    self?.image = image
                }
            }
            
            task.resume()
        }
    }
}

extension TCImageView {
    func configure() {
        self.backgroundColor    = .quaternarySystemFill
        self.clipsToBounds      = true
    }
}
