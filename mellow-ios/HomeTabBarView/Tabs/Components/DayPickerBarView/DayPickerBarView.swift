//
//  DayPickerBarView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI

struct DayPickerBarView: View {
    @Binding var date: Date?
    
    var body: some View {
        VStack {
            DayPickerBarViewRepresentable(selectedDate: $date)
                .frame(height: 44)
        }
    }
}

#Preview {
    DayPickerBarView(date: .init(get: { .now },
                                 set: { _ in }))
}



import Foundation

extension Date {
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
            fatalError("Something went relly wrong with midday date generation")
        }
        
        return middayDate
    }
    
    func dateWithoutMinutes() -> Date {
         let calendar = Calendar.current
         let components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
         let adjustedDate = calendar.date(from: components)!
         return adjustedDate
     }
    
    func dateWithoutMinuteHours() -> Date {
         let calendar = Calendar.current
         let components = calendar.dateComponents([.year, .month, .day], from: self)
         let adjustedDate = calendar.date(from: components)!
         return adjustedDate
     }
}
