//
//  SleepSessionViewRepresentation.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 23/10/2024.
//

import Foundation

struct SleepSessionViewRepresentation: Hashable {
    let id: String
    let startDate: Date
    let endDate: Date
    let type: SleepSessionType
    let formattedTimeRange: String
    let isScheduled: Bool
}

extension SleepSessionViewRepresentation {
    
    static func mocked() -> SleepSessionViewRepresentation {
        return SleepSessionViewRepresentation(
            id: UUID().uuidString,
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600), // 1 hour later
            type: .nap, // Assuming 'regular' is a case of SleepSessionType
            formattedTimeRange: "10:00 PM - 11:00 PM",
            isScheduled: true
        )
    }
    
    func toSleepSession() -> SleepSession {
        return SleepSession(
            id: self.id,
            startDate: self.startDate,
            endDate: self.endDate,
            type: self.type.rawValue
        )
    }
}
