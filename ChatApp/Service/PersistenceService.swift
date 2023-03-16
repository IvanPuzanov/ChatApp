//
//  PersistenceService.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 14.03.2023.
//

import Foundation

final class PersistenceService {
    func save<T: Encodable>(_ value: T, forKey key: Project.UserDefaultsKeys) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(value)
            
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: key.rawValue)
        } catch {
            print("fail to save")
        }
    }
    
    func fetchTheme() -> Theme? {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: Project.UserDefaultsKeys.settings.rawValue) as? Data else { return nil }
        
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(Theme.self, from: data)
            
            return decodedData
        } catch {
            print("fail to fetch")
            return nil
        }
    }
}
