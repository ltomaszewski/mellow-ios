//
//  Array+ScheduledSleepSession.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 23/10/2024.
//

import Foundation

// Extension on Array of ScheduledSleepSession
extension Array where Element == ScheduledSleepSession {
    func toViewRepresentations() -> [SleepSessionViewRepresentation] {
        return self.map { scheduledSession in
            let sessionTypeString: String
            switch scheduledSession.type {
            case .nightSleep:
                sessionTypeString = "nightSleep"
            case .nap(let number):
                sessionTypeString = "nap\(number)"
            }
            let id = "scheduled_\(sessionTypeString)_\(scheduledSession.startTime.timeIntervalSince1970)"
            let type: SleepSessionType
            switch scheduledSession.type {
            case .nightSleep:
                type = .nighttime
            case .nap(_):
                type = .nap
            }
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let formattedStartTime = formatter.string(from: scheduledSession.startTime)
            let formattedEndTime = formatter.string(from: scheduledSession.endTime)
            let formattedTimeRange = "\(formattedStartTime) - \(formattedEndTime)"
            
            return SleepSessionViewRepresentation(
                id: id,
                startDate: scheduledSession.startTime,
                endDate: scheduledSession.endTime,
                type: type,
                formattedTimeRange: formattedTimeRange,
                isScheduled: true
            )
        }
    }
}
