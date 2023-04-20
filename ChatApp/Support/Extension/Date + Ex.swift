//
//  Date + Ex.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 07.03.2023.
//

import Foundation

extension Date {
    static func createDate(day: Int, month: Int, year: Int) -> Date? {
        let calendar = Calendar.current
        let dateComponents = DateComponents(calendar: calendar, timeZone: .current, year: year, month: month, day: day)
        let date = calendar.date(from: dateComponents)
        
        return date
    }
    
    enum ConvertCase {
        case channel
        case conversation
    }
    func convert(for convertCase: ConvertCase) -> String {
        switch convertCase {
        case .channel:
            return convertToMonthDayFormat()
        case .conversation:
            let calendar = Calendar.current
            let dateFromatter = DateFormatter()
            dateFromatter.dateFormat = "MMM, dd, yyyy"
            
            if calendar.isDateInToday(self) {
                return Project.Title.Date.today
            } else if calendar.isDateInYesterday(self) {
                return Project.Title.Date.yesterday
            } else {
                return dateFromatter.string(from: self)
            }
        }
    }
    
    private func convertToMonthDayFormat() -> String {
        let calendar = Calendar.current
        let dateFromatter = DateFormatter()
        var dateFormat: String
        
        switch calendar.isDateInToday(self) {
        case true:
            dateFormat = "HH:mm"
        case false:
            dateFormat = "MMM, dd"
        }
        dateFromatter.dateFormat = dateFormat
        
        return dateFromatter.string(from: self)
    }
    
    func showOnlyTime() -> String {
        let dateFromatter = DateFormatter()
        dateFromatter.dateFormat = "HH:mm"
        
        return dateFromatter.string(from: self)
    }
    
    func isToday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }
}

extension DateComponents: Comparable {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        if let firstDate = Calendar.current.date(from: lhs), let secondDate = Calendar.current.date(from: rhs) {
            return firstDate < secondDate
        }
        
        return false
    }
}
