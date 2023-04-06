//
//  MainVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.02.2023.
//

import UIKit

class MainVC: UIViewController {
    // MARK: - Parameters
    
    public var coordintor: AppCoordinator?
    
    // MARK: - Views
    
    private let showDetailButton = UIButton()
}

// MARK: - Lifecycle

extension MainVC {
    // Данный метод вызывается после того, как view
    // был загружен. По заданию его вызов и print(#function)
    // НЕ требуется, поэтому использую его только для
    // установки цвета фона и настройки кнопки перехода
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        configureShowDetailButton()
    }
    
    // Данный метод вызывается ПЕРЕД тем, как view появится
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        printLifecycleMethod(#function)
    }
    
    // Данный метод вызывается, чтобы уведомить ViewController
    // о том, что его view собирается 'расположить' свои subviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        printLifecycleMethod(#function)
    }
    
    // Данный метод вызывается, чтобы уведомить ViewController
    // о том, что его view 'расположил' свои subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        printLifecycleMethod(#function)
    }
    
    // Данный метод вызывается ПОСЛЕ того, как view появился
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        printLifecycleMethod(#function)
    }
    
    // Данный метод вызывается ПЕРЕД тем, как этот
    // view будет удален из иерархии view
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        printLifecycleMethod(#function)
    }
    
    // Данный метод вызывается ПОСЛЕ того, как этот
    // view был удален из иерархии view
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        printLifecycleMethod(#function)
    }
}

// MARK: - Event methods

private extension MainVC {
    @objc
    func buttonTapped(_ sender: UIButton) {
        switch sender {
        case showDetailButton:
            coordintor?.showDetailedVC()
        default:
            break
        }
    }
}

// MARK: - Configure methods

private extension MainVC {
    func configure() {
        self.view.backgroundColor = .systemBackground
    }
    
    // Переход на другой контроллер написан только
    // для демонстрации работы методов view(Will/Did)Disapper
    func configureShowDetailButton() {
        self.view.addSubview(showDetailButton)
        showDetailButton.translatesAutoresizingMaskIntoConstraints = false
        
        showDetailButton.backgroundColor = .quaternarySystemFill
        showDetailButton.setTitle("Show detail", for: .normal)
        showDetailButton.setTitleColor(.label, for: .normal)
        showDetailButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        showDetailButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            showDetailButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            showDetailButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            showDetailButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            showDetailButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
