//
//  URL + Ex.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 25.04.2023.
//

import UIKit

extension URL {
    var isValid: Bool {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return false }
        let matches = detector.matches(in: self.absoluteString, options: [], range: NSRange(location: 0, length: self.absoluteString.utf16.count))

        for match in matches {
            guard let range = Range(match.range, in: self.absoluteString) else { continue }
            return true
        }
        
        return false
    }
}
