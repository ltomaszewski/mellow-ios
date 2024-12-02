//
//  Array+SleepSession.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 20/10/2024.
//

import Foundation

extension Array where Element == SleepSessionViewRepresentation {
    func hasSession(on date: Date) -> Bool {
        let calendar = Calendar.current
        for session in self {
            guard !session.isScheduled else { continue }
            let sessionDayComponents = calendar.dateComponents([.year, .month, .day], from: session.startDate)
            let givenDayComponents = calendar.dateComponents([.year, .month, .day], from: date)
            if sessionDayComponents == givenDayComponents {
                return true
            }
        }
        return false
    }
    
    func nightSleepEnding(on date: Date) -> SleepSessionViewRepresentation? {
        let calendar = Calendar.current
        
        // Find the start of the day for the input date
        let startOfDay = calendar.startOfDay(for: date)
        
        return self.first { session in
            // Check if the session is of type .nightSleep
            guard session.type == .nighttime else {
                return false
            }
            
            // Ensure the session ended on the given date
            guard let endDate = session.endDate, calendar.isDate(endDate, inSameDayAs: startOfDay) else {
                return false
            }
            
            // Ensure the session started the day before
            let dayBefore = calendar.date(byAdding: .day, value: -1, to: startOfDay)
            guard let startDate = dayBefore, calendar.isDate(session.startDate, inSameDayAs: startDate) else {
                return false
            }
            
            return true
        }
    }
}

extension Array where Element == SleepSession {
    func hasSession(on date: Date) -> Bool {
        let calendar = Calendar.current
        for session in self {
            let sessionDayComponents = calendar.dateComponents([.year, .month, .day], from: session.startDate)
            let givenDayComponents = calendar.dateComponents([.year, .month, .day], from: date)
            if sessionDayComponents == givenDayComponents {
                return true
            }
        }
        return false
    }

    func totalHours() -> Double {
        return self.reduce(0) { total, session in
            let duration = (session.endDate ?? .now).timeIntervalSince(session.startDate)
            return total + (duration / 3600) // Convert seconds to hours
        }
    }

    func numberOfDaysWithAtLeastOneSession() -> Int {
        let calendar = Calendar.current
        var uniqueDays = Set<DateComponents>()
        for session in self {
            let dayComponents = calendar.dateComponents([.year, .month, .day], from: session.startDate)
            uniqueDays.insert(dayComponents)
        }
        return uniqueDays.count
    }
}
