//
//  Date+Extensions.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 14/08/2024.
//

import Foundation

extension Date {
    /// Creates a date at 8:00 AM for the current date.
    /// - Returns: A new date with the time set to 8:00 AM.
    func morning() -> Date {
        return self.setHour(8)
    }
    
    /// Creates a date at 8:00 PM for the current date.
    /// - Returns: A new date with the time set to 8:00 PM.
    func evening() -> Date {
        return self.setHour(20)
    }
    
    /// Sets the hour of the current date to a specified value.
    /// - Parameter hour: The hour value to set (0-23).
    /// - Returns: A new date with the specified hour.
    func setHour(_ hour: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.hour = hour
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)!
    }
    
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
    
    /// Checks if the time difference between this date and another date is more than the specified number of hours.
    /// - Parameters:
    ///   - otherDate: The date to compare with.
    ///   - hours: The number of hours to check against.
    /// - Returns: A Boolean value indicating whether the time difference is more than the specified number of hours.
    func isTimeDifferenceMoreThan(hours: Int, comparedTo otherDate: Date) -> Bool {
        // Calculate the time difference in seconds
        let timeDifference = self.timeIntervalSince(otherDate)
        
        // Convert the specified hours into seconds
        let hoursInSeconds = Double(hours) * 60 * 60
        
        // Check if the time difference is greater than the specified hours
        return abs(timeDifference) > hoursInSeconds
    }
    
    /// Checks if the date is today, considering only the year, month, and day.
    /// - Returns: A Boolean value indicating whether the date is today.
    func isToday() -> Bool {
        let calendar = Calendar.current
        // Extract the year, month, and day components of the current date and the date to compare
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let selfComponents = calendar.dateComponents([.year, .month, .day], from: self)
        
        // Compare year, month, and day components
        return todayComponents == selfComponents
    }
    
    /// Adjusts the date to the start of the day (00:00:00).
    /// - Returns: A new date with time set to the start of the day.
    func startOfDay() -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: self)
    }
    
    /// Checks if the date is within the range of two dates.
    /// - Parameters:
    ///   - startDate: The start date of the range.
    ///   - endDate: The end date of the range.
    /// - Returns: A Boolean value indicating whether the date is within the range.
    func isBetween(_ startDate: Date, and endDate: Date) -> Bool {
        return (self >= startDate) && (self <= endDate)
    }
}
