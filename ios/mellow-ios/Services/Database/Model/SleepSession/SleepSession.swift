//
//  SleepSessionDB.swift
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
class SleepSession {
    @Attribute(.unique) var id: String // UUID has probelms with SwiftData, funny fact
    var startDate: Date
    var endDate: Date?
    var type: String

    init(id: String = UUID().uuidString, startDate: Date, endDate: Date?, type: String) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
    }
    
    var formattedTimeRange: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let startString = dateFormatter.string(from: startDate)
        
        if let endDate = endDate {
            let endString = dateFormatter.string(from: endDate)
            return "\(startString) – \(endString)"
        } else {
            return "\(startString)"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(startDate)
        hasher.combine(endDate)
    }
}

@Printable
enum SleepSessionType: String, CaseIterable {
    case nighttime = "Nighttime Sleep"
    case nap = "Nap"
}

extension SleepSession {
    func toViewRepresentation() -> SleepSessionViewRepresentation {
        return SleepSessionViewRepresentation(
            id: self.id,
            startDate: self.startDate,
            endDate: self.endDate,
            type: SleepSessionType(rawValue: self.type) ?? .nighttime, // Default to nighttime if type doesn't match
            formattedTimeRange: self.formattedTimeRange,
            isScheduled: false // Since all objects of type SleepSession are not scheduled
        )
    }
}
