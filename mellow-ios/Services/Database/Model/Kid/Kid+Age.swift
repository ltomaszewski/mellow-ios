//
//  Kid+Age.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 09/11/2024.
//

import Foundation

extension Kid {
    var ageInMonths: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.month], from: dateOfBirth, to: now)
        return components.month ?? 0
    }
    
    var ageFormatted: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: dateOfBirth, to: now)
        
        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0
        
        if years >= 1 {
            var ageParts: [String] = []
            
            // Years
            let yearString = years == 1 ? "1 year" : "\(years) years"
            ageParts.append(yearString)
            
            // Months
            if months > 0 {
                let monthString = months == 1 ? "1 month" : "\(months) months"
                ageParts.append(monthString)
            }
            
            return ageParts.joined(separator: " ")
            
        } else if months >= 1 {
            var ageParts: [String] = []
            
            // Months
            let monthString = months == 1 ? "1 month" : "\(months) months"
            ageParts.append(monthString)
            
            // Days
            if days > 0 {
                let dayString = days == 1 ? "1 day" : "\(days) days"
                ageParts.append(dayString)
            }
            
            return ageParts.joined(separator: " ")
            
        } else {
            // Days (less than a month)
            let dayString = days == 1 ? "1 day" : "\(days) days"
            return dayString
        }
    }
}
