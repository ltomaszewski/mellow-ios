//
//  SleepSessionViewRepresentation.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 23/10/2024.
//

import Foundation
import SwiftlyBeautiful

@Printable
struct SleepSessionViewRepresentation: Hashable {
    let id: String
    let startDate: Date
    let endDate: Date?
    let type: SleepSessionType
    let formattedTimeRange: String
    let isScheduled: Bool
    var isInProgress: Bool {
        endDate == nil
    }
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
    
    // Method to check if two sleep sessions overlap
    func overlaps(with other: SleepSessionViewRepresentation?) -> Bool {
        guard let other else { return false }
        guard isScheduled else { return false}
        
        let currentEndDate = self.endDate ?? Date()
        let otherCurrentEndDate = other.endDate ?? Date()

        return !(self.startDate >= otherCurrentEndDate || currentEndDate <= other.startDate)
    }
}
