//
//  PersistenceService.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 14.03.2023.
//

import Foundation

final class UserDefaultsService {
    /// Сохранение данных
    /// - Parameters:
    ///   - value: Данные для сохранения
    ///   - key: Ключ сохранения
    func save<T: Encodable>(_ value: T, forKey key: Project.UserDefaultsKeys) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(value)
            
            let userDefaults = UserDefaults.standard
            
            DispatchQueue.global(qos: .utility).async {
                userDefaults.set(encodedData, forKey: key.rawValue)
            }
        } catch {}
    }
    
    /// Запрос сохраненной темы
    /// - Returns: Тема приложения
    func fetchTheme() -> Theme? {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: Project.UserDefaultsKeys.themeSettings.rawValue) as? Data else { return nil }
        
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(Theme.self, from: data)
            
            return decodedData
        } catch {
            return nil
        }
    }
}
