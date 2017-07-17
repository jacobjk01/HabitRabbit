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
    
    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        if (self == date1 || self == date2) {
            return true
        } else if (self > date1 && self < date2) {
            return true
        }
        return false
    }
}
