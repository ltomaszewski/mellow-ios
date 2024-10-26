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
}
