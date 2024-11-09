//
//  Kid.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 05/09/2024.
//

import SwiftData
import Foundation
import SwiftlyBeautiful

@Model
@Printable
@SwiftDataCRUD
class Kid {
    @Attribute(.unique) var id: String
    var name: String
    var dateOfBirth: Date?
    var isHim: Bool
    var sleepSessions: [SleepSession] = []
    
    init(name: String, dateOfBirth: Date? = nil) {
        self.id = UUID().uuidString
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.isHim = true
    }
    
    func addSleepSession(_ session: SleepSession) {
        sleepSessions.append(session)
    }
    
    func removeSleepSession(_ session: SleepSession) {
        if let index = sleepSessions.firstIndex(where: { $0.id == session.id }) {
            sleepSessions.remove(at: index)
        }
    }
    
    func replaceSleepSession(id: String, with newSession: SleepSession) {
        if let index = sleepSessions.firstIndex(where: { $0.id == id }) {
            let oldSession = sleepSessions[index]
            oldSession.type = newSession.type
            oldSession.startDate = newSession.startDate
            oldSession.endDate = newSession.endDate
        }
    }
}

extension Kid {
    var ageInMonths: Int {
        guard let dateOfBirth = dateOfBirth else {
            return 0
        }
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.month], from: dateOfBirth, to: now)
        return components.month ?? 0
    }
    
    var ageFormatted: String {
        guard let dateOfBirth = dateOfBirth else {
            return "Age unknown"
        }
        
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
