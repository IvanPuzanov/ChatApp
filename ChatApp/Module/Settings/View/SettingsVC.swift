//
//  ThemeVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 09.03.2023.
//

import UIKit
import Combine

final class SettingsVC: UIViewController {
    // MARK: - Параметры
    
    private let input            = PassthroughSubject<SettingsViewModel.Input, Never>()
    private let viewModel        = SettingsViewModel()
    private var disposeBag       = Set<AnyCancellable>()
    
    // MARK: - UI
    
    private var stackView        = UIStackView()
    private let darkThemeButton  = TCThemeView(theme: .dark)
    private let lightThemeButton = TCThemeView(theme: .light)
    
}

// MARK: - Жизненный цикл

extension SettingsVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        configure()
        configureNavigationBar()
        configureStackView()
        configureThemeButtons()
        validateAppearance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        input.send(.save)
    }
}

// MARK: - Методы событий

extension SettingsVC {
    @objc
    private func themeButtonTapped(_ sender: TCThemeView) {
        switch sender {
        case darkThemeButton:
            lightThemeButton.isSelected(false)
            darkThemeButton.isSelected(true)
    
            UIView.animate(withDuration: 0.3) {
                self.view.window?.overrideUserInterfaceStyle = .dark
            }            
        case lightThemeButton:
            lightThemeButton.isSelected(true)
            darkThemeButton.isSelected(false)
            
            UIView.animate(withDuration: 0.3) {
                self.view.window?.overrideUserInterfaceStyle = .light
            }
        default:
            break
        }
    }
    
    private func validateAppearance() {
        switch traitCollection.userInterfaceStyle {
        case .light:
            lightThemeButton.isSelected(true)
        case .dark:
            darkThemeButton.isSelected(true)
        default:
            lightThemeButton.isSelected(true)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        configure()
    }
}

// MARK: - Методы конфигурации

private extension SettingsVC {
    func bindViewModel() {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        
        output.sink { _ in
        }.store(in: &disposeBag)
    }
    
    func configure() {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            self.view.backgroundColor = .systemBackground
        default:
            self.view.backgroundColor = .secondarySystemBackground
        }
    }
    
    func configureNavigationBar() {
        self.navigationItem.title = Project.Title.settings
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    func configureStackView() {
        stackView = UIStackViewBuilder()
            .withAxis(.horizontal)
            .withCorner(radius: 18)
            .withMargins(top: 20, bottom: 20)
            .withDistribution(.fillEqually)
            .withBackgroundColor(Project.Color.subviewBackground)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build()
        
        self.view.addSubview(stackView)
        
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
