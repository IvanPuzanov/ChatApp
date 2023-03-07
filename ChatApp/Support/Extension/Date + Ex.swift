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
        let dateComponents = DateComponents(calendar: calendar, timeZone: .current, era: nil, year: year, month: month, day: day, hour: nil, minute: nil, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
        let date = calendar.date(from: dateComponents)
        
        return date
    }
    
    func convertToMonthYearFormat() -> String {
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
