//
//  ThemeVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 09.03.2023.
//

import UIKit

/*
    ДОМАШНЕЕ ЗАДАНИЕ
 
 
    Retain Cycle можно возникнуть, если данный контроллер и
    другой объект будут сильно ссылаться друг на друга,
    тем самым не позволяя друг другу высвободиться из памяти.
 
    [       Person       ]                [       Laptop        ]
    [ var laptop: Laptop ] <---STRONG---> [  var owner: Person  ]
    
    Например, каждый контроллер в моем приложении имеет свой presenter,
    который имеет слабую(weak) ссылку на контроллер, чтобы исключить
    подобный сценарий.
*/

final class ThemeVC: UIViewController {
    // MARK: - Делегирование и замыкание
    public weak var themeDelegate: ThemePresenterProtocol?
    public var themeDidSet: ((Theme) -> ())?
    
    // MARK: - Параметры
    private var presenter = ThemePresenter()
    
    // MARK: - UI
    private let stackView           = UIStackView()
    private let darkThemeButton     = TCThemeView(theme: .dark)
    private let lightThemeButton    = TCThemeView(theme: .light)
}

// MARK: - Жизненный цикл
extension ThemeVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        configureNavigationBar()
        configureStackView()
        configureThemeButtons()
        validateAppearance()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Сохранение выбранной темы происходит при
        // исчезновении контроллера, чтобы избежать
        // частой перезаписи в память, если пользователь
        // несколько раз переключает темы 'за один раз'
        presenter.saveTheme()
    }
}

// MARK: - Методы событий
private extension ThemeVC {
    @objc
    func themeButtonTapped(_ sender: TCThemeView) {
        switch sender {
        case darkThemeButton:
            lightThemeButton.isSelected(false)
            darkThemeButton.isSelected(true)
    
            themeDidSet?(.dark)
            themeDelegate?.themeDidSet(.dark)
            
            UIView.animate(withDuration: 0.3) {
                self.view.window?.overrideUserInterfaceStyle = .dark
            }            
        case lightThemeButton:
            lightThemeButton.isSelected(true)
            darkThemeButton.isSelected(false)
            
            themeDidSet?(.light)
            themeDelegate?.themeDidSet(.light)
            
            UIView.animate(withDuration: 0.3) {
                self.view.window?.overrideUserInterfaceStyle = .light
            }
        default:
            break
        }
    }
    
    func validateAppearance() {
        switch traitCollection.userInterfaceStyle {
        case .light:
            lightThemeButton.isSelected(true)
        case .dark:
            darkThemeButton.isSelected(true)
        default:
            lightThemeButton.isSelected(true)
        }
    }
}

// MARK: - Методы конфигурации
private extension ThemeVC {
    func bindToPresenter() {
        self.presenter.setDelegate(self)
    }
    
    func configure() {
        self.view.backgroundColor = .secondarySystemBackground
    }
    
    func configureNavigationBar() {
        self.navigationItem.title = Project.Title.settings
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    func configureStackView() {
        self.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.distribution                          = .fillEqually
        stackView.backgroundColor                       = Project.Color.subviewBackground
        stackView.layer.cornerRadius                    = 18
        stackView.layoutMargins                         = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        stackView.isLayoutMarginsRelativeArrangement    = true
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    func configureThemeButtons() {
        stackView.addArrangedSubview(lightThemeButton)
        stackView.addArrangedSubview(darkThemeButton)
        
        [darkThemeButton, lightThemeButton].forEach {
            $0.addTarget(self, action: #selector(themeButtonTapped), for: .touchUpInside)
        }
    }
}

// MARK: - ThemePresenterProtocol
extension ThemeVC: ThemePresenterProtocol {
    func themeDidSet(_ theme: Theme) {
        
    }
}