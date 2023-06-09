//
//  String + Ex.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 07.03.2023.
//

import Foundation

extension String {
    
    func convertToDate() -> Date? {
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale        = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone      = .current
        
        return dateFormatter.date(from: self)
    }
    
    func convertToDisplayFormat() -> String {
        guard let date = self.convertToDate() else { return "N/A" }
        return date.convert(for: .channel)
    }
    
    func isURL() -> Bool {
        guard let url = URL(string: self) else { return false }
        return url.isValid
    }
}
