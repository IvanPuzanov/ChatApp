//
//  FileService.swift
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

final class FileService {
    // MARK: - Singleton
    static let shared = FileService()
    private init() {}
    
    // MARK: - Параметры
    public var currentUser = User.defaultUser
    private var currentUserData: Data = Data() {
        didSet { userSubject.send(currentUserData) }
    }
    private let manager: FileManager = .default
    
    // MARK: - Combine publishers
    public var userPublisher: AnyPublisher<Data, Never> {
        userSubject.eraseToAnyPublisher()
    }
    public let userSubject = PassthroughSubject<Data, Never>()
    
}

extension FileService {
    private func makeDefaultUser() {
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
            self.currentUserData = encodedDefaultUser
            return
        } catch {
            return
        }
    }
    
    func fetchUser() {
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
                currentUserData = userFile
                return
            }
            
            // Сохранение текущей картинки и возврат пользователя с картинкой
            decodedUser.avatar = avatar
            
            let encoder = JSONEncoder()
            let encodedUser = try encoder.encode(decodedUser)
            
            self.currentUser = decodedUser
            self.currentUserData = encodedUser
            return
        } catch {}
    }
    
    func save(user: User) throws {
        // Ссылки на директории
        let url             = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        let userDirectory   = url?.appendingPathComponent("user-profile")
        let userData        = userDirectory?.appendingPathComponent("data.txt")
        let userAvatar      = userDirectory?.appendingPathComponent("avatar.png")
        
        guard let userData else { return }
        
        var encodedUser: Data = Data()
        
        // Проверка измененных текстовых данных пользователя
        if user.name != currentUser.name || user.bio != currentUser.bio {
            do {
                let encoder     = JSONEncoder()
                encodedUser = try encoder.encode(user)
                
                try encodedUser.write(to: userData)
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
                encodedUser = try encoder.encode(user)
            } catch {
                throw _FileServiceError.failToSave
            }
        }
        
        self.currentUser = user
        self.currentUserData = encodedUser
    }
}
