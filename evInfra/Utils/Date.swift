//
//  Date.swift
//  evInfra
//
//  Created by Shin Park on 15/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

extension Date {
    
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    func toStringToMinute(data: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dataFormmaterForBoard = DateFormatter()
        dataFormmaterForBoard.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let date: Date = dateFormatter.date(from: data) {
            return dataFormmaterForBoard.string(from: date)
        } else {
            return ""
        }
    }
    
    func toDate(data: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        if let date: Date = dateFormatter.date(from: data) {
            return date
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter.date(from: data)
        }
    }
    
    func offsetFrom(date: Date) -> String {
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self);
        
        let minutes = "\(difference.minute ?? 0)분"
        let hours = "\(difference.hour ?? 0)시간" + " " + minutes
        let days = "\(difference.day ?? 0)일" + " " + hours
        
        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        
        return ""
    }
    
    func getYesterday() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)
    }
    
    func getLast7Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -7, to: self)
    }
    func getLast30Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -30, to: self)
    }
    
    func getLast6Month() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -6, to: self)
    }
    
    func getLast3Month() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -3, to: self)
    }
    
    func getPreviousMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)
    }
    
    // This Month Start
    func getThisMonthStart() -> Date? {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }
    
    // This Month End
    func getThisMonthEnd() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month += 1
        components.day = 1
        components.day -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    // Last Month Start
    func getLastMonthStart() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    // Last Month End
    func getLastMonthEnd() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.day = 1
        components.day -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    func getThisYearStart() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year], from: self) as NSDateComponents
        components.month = 1
        components.day = 1
        return Calendar.current.date(from: components as DateComponents)!
    }
}
