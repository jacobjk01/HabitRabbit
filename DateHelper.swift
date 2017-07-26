//
//  Date.swift
//  HabitTrack
//
//  Created by Jacob Kim on 7/10/17.
//  Copyright © 2017 Jacob Kim. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func monthAsString() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMM")
        return df.string(from: self)
    }
    
    func isBetween(date date1: NSDate, andDate date2: NSDate) -> Bool {
        let newDate = date1.addingTimeInterval(-Double(60*60*24))
        return newDate.compare(self).rawValue * self.compare(date2 as Date).rawValue >= 0
    }
    
    func getDateOfNextYear() -> Date {
        var components = Calendar.current.dateComponents([.year], from: Date())
        if let startDateOfYear = Calendar.current.date(from: components) {
            components.year = 1
            return Calendar.current.date(byAdding: components, to: startDateOfYear)!
        }
        return Date()
    }
    
    func isWeekDay() -> Bool {
        let today = self
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let components = calendar!.components([.weekday], from: today)
        
        if components.weekday! > 1 && components.weekday! < 7 {
            return true
        } else {
            return false
        }
    }
    
    func isWeekend() -> Bool {
        let today = self
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let components = calendar!.components([.weekday], from: today)
        
        if components.weekday! == 1 || components.weekday! == 7 {
            return true
        } else {
            return false
        }
    }
    
    func isFriday() -> Bool {
        let today = self
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let components = calendar!.components([.weekday], from: today)
        
        if components.weekday == 6 {
            return true
        } else {
            return false
        }
    }
    
    func isSunday() -> Bool {
        let today = self
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let components = calendar!.components([.weekday], from: today)
        
        if components.weekday == 1 {
            return true
        } else {
            return false
        }
    }
    
    func isMonday() -> Bool {
        let today = self
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let components = calendar!.components([.weekday], from: today)
        
        if components.weekday == 2 {
            return true
        } else {
            return false
        }
    }
    
    func isSaturday() -> Bool {
        let today = self
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let components = calendar!.components([.weekday], from: today)
        
        if components.weekday == 7 {
            return true
        } else {
            return false
        }
    }
}
