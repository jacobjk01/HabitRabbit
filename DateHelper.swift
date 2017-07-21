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
}
