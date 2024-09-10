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
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date
    var type: String

    init(id: UUID = UUID(), startDate: Date, endDate: Date, type: String) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
    }
    
    var formattedTimeRange: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let startString = dateFormatter.string(from: startDate)
        let endString = dateFormatter.string(from: endDate)
        
        return "\(startString) – \(endString)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(startDate)
        hasher.combine(endDate)
    }
}

enum SleepSessionType: String, CaseIterable {
    case nighttime = "Nighttime Sleep"
    case nap = "Nap"
}
