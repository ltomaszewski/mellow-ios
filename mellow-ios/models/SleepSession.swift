//
//  SleepModel.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 14/08/2024.
//

import Foundation

struct SleepSession: Identifiable, Hashable {
    var id: String {
        formattedTimeRange
    }
    
    let type: SleepSessionType
    let startTime: Date
    let endTime: Date
    
    var name: String {
        return switch (type) {
        case .nap:
            "Nap"
        case .nighttime:
            "Nighttime Sleep"
        }
    }
    
    var formattedTimeRange: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let startString = dateFormatter.string(from: startTime)
        let endString = dateFormatter.string(from: endTime)
        
        return "\(startString) – \(endString)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(startTime)
        hasher.combine(endTime)
    }
    
    static func == (lhs: SleepSession, rhs: SleepSession) -> Bool {
        return lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime
    }
}

enum SleepSessionType: String {
    case nighttime = "Nighttime Sleep"
    case nap = "Nap"
}

extension SleepSession {
    static func createMockedSession() -> SleepSession {
        // Current date and time
        let currentDate = Date()
        
        // Randomize the start time within ±4 hours from the current date
        let fourHoursInSeconds: TimeInterval = 24 * 60 * 60
        let randomTimeOffset = TimeInterval.random(in: -fourHoursInSeconds...fourHoursInSeconds)
        let startTime = currentDate.addingTimeInterval(randomTimeOffset)
        
        // Randomize the duration between 45 minutes (2700 seconds) and 150 minutes (9000 seconds)
        let randomDuration = TimeInterval.random(in: 2700...9000)
        let endTime = startTime.addingTimeInterval(randomDuration)
        
        // Randomly select between nap and nighttime sleep
        let randomType = Bool.random() ? SleepSessionType.nap : SleepSessionType.nighttime
        
        // Create and return the mocked SleepSession
        return SleepSession(type: randomType, startTime: startTime, endTime: endTime)
    }
    
    func printDescription() {
        let description = """
        Sleep Session Description:
        Type: \(name)
        Start Time: \(startTime)
        End Time: \(endTime)
        Start Time: \(formattedTimeRange.split(separator: "–").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        End Time: \(formattedTimeRange.split(separator: "–").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        Duration: \(endTime.timeIntervalSince(startTime) / 60) minutes
        """
        
        print(description)
    }
}
