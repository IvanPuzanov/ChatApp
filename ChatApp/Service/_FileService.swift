//
//  _FileService.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 30.03.2023.
//

import UIKit
import Combine

enum _FileServiceError: Error {
    case failToSave
    case failToFetch
}

final class _FileService {
    // MARK: - Singleton
    static let shared = _FileService()
    private init() {}
    
    // MARK: - Параметры
    private var backgroundQueue = DispatchQueue(label: "fileService.queue")
    
    public var currentUser = User.defaultUser
    private let manager: FileManager = .default
    
    // MARK: -
    public let userPublisher = PassthroughSubject<Data, Never>()
    
}

enum FileServiceURL {
    static let base          = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    static let userDirectory = base?.appendingPathComponent("user-profile")
    static let userData      = userDirectory?.appendingPathComponent("data.txt")
    static let userAvatar    = userDirectory?.appendingPathComponent("avatar.png")
}

extension _FileService {
    func makeDefaultUser() {
        // Ссылки на директории
        let url             = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        let userDirectory   = url?.appendingPathComponent("user-profile")
        let userData        = userDirectory?.appendingPathComponent("data.txt")
        
        // Стандартный пользователь
        let defaultUser     = User.defaultUser
        
        // Разворачивание ссылок директорий
        guard let userDirectory, let userData else { return }
        
        // Запись стандартного пользователя
        do {
            // Кодирование стандартного пользователя
            let encoder             = JSONEncoder()
            let encodedDefaultUser  = try encoder.encode(defaultUser)
            
            // Создание директории и запись файла
            try manager.createDirectory(at: userDirectory, withIntermediateDirectories: true)
            manager.createFile(atPath: userData.path, contents: encodedDefaultUser)
            
            // Сохранении текущего пользователя в качестве стандратного
            self.currentUser = defaultUser
            self.userPublisher.send(encodedDefaultUser)
            return
        } catch {
            return
        }
    }
    
    func fetchUser() throws {
        // Ссылки на директории
        let url             = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        let userDirectory   = url?.appendingPathComponent("user-profile")
        let userData        = userDirectory?.appendingPathComponent("data.txt")
        let userAvatar      = userDirectory?.appendingPathComponent("avatar.png")
        
        // Проверка наличия директории пользователя, иначе
        // создается стандратный пользователь
        guard let userData, let userFile = manager.contents(atPath: userData.path) else {
            makeDefaultUser()
            return
        }
        
        // Получение данных пользователя
        do {
            // Декодирование данных пользователя
            let decoder     = JSONDecoder()
            var decodedUser = try decoder.decode(User.self, from: userFile)
            
            // Проверка наличия изображения в директории
            guard let userAvatar, let avatar = manager.contents(atPath: userAvatar.path) else {
                // Возвращение полученных данных пользователя без картинки
                userPublisher.send(userFile)
                return
            }
            
            // Сохранение текущей картинки и возврат пользователя с картинкой
            decodedUser.avatar = avatar
            
            let encoder = JSONEncoder()
            let encodedUser = try encoder.encode(decodedUser)

            userPublisher.send(encodedUser)
            
            self.currentUser = decodedUser
            return
        } catch {
            throw _FileServiceError.failToFetch
        }
    }
    
    func save(user: User) throws {
        // Ссылки на директории
        let url             = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        let userDirectory   = url?.appendingPathComponent("user-profile")
        let userData        = userDirectory?.appendingPathComponent("data.txt")
        let userAvatar      = userDirectory?.appendingPathComponent("avatar.png")
        
        guard let userData else { return }
        
        // Проверка измененных текстовых данных пользователя
        if user.name != currentUser.name || user.bio != currentUser.bio {
            do {
                let encoder     = JSONEncoder()
                let encodedUser = try encoder.encode(user)
                
                try encodedUser.write(to: userData)
                userPublisher.send(encodedUser)
                self.currentUser = user
            } catch {
                throw _FileServiceError.failToSave
            }
        }
        
        // Проверка измененной картинки пользователя
        if user.avatar != currentUser.avatar {
            do {
                guard let userAvatar else { return }
                try user.avatar?.write(to: userAvatar)
                
                let encoder = JSONEncoder()
                let encodedUser = try encoder.encode(user)
                
                userPublisher.send(encodedUser)
            } catch {
                return
            }
        }
    }
}
