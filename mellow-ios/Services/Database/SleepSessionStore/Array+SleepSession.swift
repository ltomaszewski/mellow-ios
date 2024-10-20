//
//  Array+SleepSession.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 20/10/2024.
//

import Foundation

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
            let duration = session.endDate.timeIntervalSince(session.startDate)
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
