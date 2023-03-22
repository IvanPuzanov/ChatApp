//
//  FileService.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 21.03.2023.
//

import Foundation

enum FileServiceError: Error {
    case failToSave(User)
    case failToSaveImage
}

final class FileService {
    // MARK: - Singleton
    static let shared = FileService()
    private init() {}
    
    // MARK: - Параметры
    private let manager: FileManager = .default
    public var currentUser: User?
}

private extension FileService {
    func makeDefaultUser() -> User? {
        // Ссылки на директории
        let url             = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        let userDirectory   = url?.appendingPathComponent("user-profile")
        let userData        = userDirectory?.appendingPathComponent("data.txt")
        
        // Стандартный пользователь
        let defaultUser     = User.defaultUser
        
        // Разворачивание ссылок директорий
        guard let userDirectory, let userData else { return nil }
        
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
            return defaultUser
        } catch {
            return nil
        }
    }
}

extension FileService {
    func fetchUserProfile() -> User? {
        // Ссылки на директории
        let url             = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        let userDirectory   = url?.appendingPathComponent("user-profile")
        let userData        = userDirectory?.appendingPathComponent("data.txt")
        let userAvatar      = userDirectory?.appendingPathComponent("avatar.png")
        
        // Проверка наличия директории пользователя, иначе
        // создается стандратный пользователь
        guard let userData, let userFile = manager.contents(atPath: userData.path) else {
            let defaultUser = makeDefaultUser()
            return defaultUser
        }
        
        // Получение данных пользователя
        do {
            // Декодирование данных пользователя
            let decoder     = JSONDecoder()
            var decodedUser = try decoder.decode(User.self, from: userFile)
            
            // Проверка наличия изображения в директории
            guard let userAvatar, let avatar = manager.contents(atPath: userAvatar.path) else {
                // Возвращение полученных данных пользователя без картинки
                self.currentUser = decodedUser
                return decodedUser
            }
            
            // Сохранение текущей картинки и возврат пользователя с картинкой
            decodedUser.avatar = avatar
            self.currentUser = decodedUser
            
            return decodedUser
        } catch {
            return nil
        }
        
    }
    
    func save(user: User, completion: @escaping (Result<User?, FileServiceError>) -> Void) {
        // Ссылки на директории
        let url             = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        let userDirectory   = url?.appendingPathComponent("user-profile")
        let userData        = userDirectory?.appendingPathComponent("data.txt")
        let userAvatar      = userDirectory?.appendingPathComponent("avatar.png")
        
        guard let userData else { return }
        guard let currentUser else {
            completion(.failure(.failToSave(user)))
            return
        }
        
        // Проверка измененных текстовых данных пользователя
        if user.name != currentUser.name || user.bio != currentUser.bio {
            do {
                let encoder     = JSONEncoder()
                let encodedUser = try encoder.encode(user)
                
                try encodedUser.write(to: userData)
                self.currentUser = user
            } catch {
                completion(.failure(.failToSave(currentUser)))
                return
            }
        }
        
        // Проверка измененной картинки пользователя
        if user.avatar != currentUser.avatar {
            do {
                guard let userAvatar else { return }
                try user.avatar?.write(to: userAvatar)
            } catch {
                completion(.failure(.failToSaveImage))
                return
            }
        }
    
        completion(.success(user))
    }
}
