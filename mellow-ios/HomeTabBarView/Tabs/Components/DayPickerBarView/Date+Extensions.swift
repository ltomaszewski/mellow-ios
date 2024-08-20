//
//  Date+Extensions.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 14/08/2024.
//

import Foundation

extension Date {
    func adjustDay(by days: Int) -> Date {
        guard let newDay = Calendar.current.date(byAdding: .day, value: days, to: self) else {
            fatalError("Something went wrong during day creation in calendar pager for ")
        }
        return newDay
    }
    
    /// Adds or subtracts the specified number of hours from the current date.
    /// - Parameter hours: The number of hours to add (positive) or subtract (negative).
    /// - Returns: A new date adjusted by the specified number of hours.
    func adding(hours: Int) -> Date? {
        // Create a DateComponents instance with the specified number of hours
        var dateComponents = DateComponents()
        dateComponents.hour = hours
        
        // Use the current calendar to adjust the date
        let newDate = Calendar.current.date(byAdding: dateComponents, to: self)
        
        return newDate
    }
    
    /// Adjusts the date to midday (12:00 PM).
    /// - Returns: A new date with the time set to 12:00 PM.
    func adjustToMidday() -> Date {
        // Get the current calendar
        let calendar = Calendar.current
        
        // Extract the year, month, and day components of the current date
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        
        // Set the time components to midday (12:00 PM)
        components.hour = 12
        components.minute = 0
        components.second = 0
        
        // Create a new date with the specified components
        guard let middayDate = calendar.date(from: components) else {
            fatalError("Something went really wrong with midday date generation")
        }
        
        return middayDate
    }
    
    /// Returns a new date with the time components set to the hour only, excluding minutes.
    /// - Returns: A new date without minutes.
    func dateWithoutMinutes() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        let adjustedDate = calendar.date(from: components)!
        return adjustedDate
    }
    
    /// Returns a new date with the time components set to the start of the day (00:00:00).
    /// - Returns: A new date without hour and minute.
    func dateWithoutMinuteHours() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        let adjustedDate = calendar.date(from: components)!
        return adjustedDate
    }

    /// Calculates the number of minutes between the current date and another date.
    /// - Parameter toDate: The date to compare to.
    /// - Returns: The number of minutes between the two dates.
    func minutes(from toDate: Date) -> Int {
        let difference = Calendar.current.dateComponents([.minute], from: self, to: toDate)
        return difference.minute ?? 0
    }
}
