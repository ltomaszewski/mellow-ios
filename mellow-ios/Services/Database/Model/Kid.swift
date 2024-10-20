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
    var age: String
    var isHim: Bool
    var sleepSessions: [SleepSession] = []
    
    init(name: String, age: String) {
        self.id = UUID().uuidString
        self.name = name
        self.age = age
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
