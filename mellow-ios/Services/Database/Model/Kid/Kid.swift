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
    var dateOfBirth: Date
    var isHim: Bool
    var sleepTime: Date
    var wakeTime: Date
    var sleepSessions: [SleepSession] = []
    
    init(name: String, dateOfBirth: Date, sleepTime: Date, wakeTime: Date) {
        self.id = UUID().uuidString
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.sleepTime = sleepTime
        self.wakeTime = wakeTime
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
    func toProfileKidsListViewItem() -> ProfileKidsListView.KidViewModel {
        return ProfileKidsListView.KidViewModel(
            name: self.name,
            ageFormatted: self.ageFormatted,
            imageResource: .kidoHim,
            databaseKidsID: self.id
        )
    }
}

extension Array where Element == Kid {
    func toProfileKidsListViewItems() -> [ProfileKidsListView.KidViewModel] {
        return self.map { $0.toProfileKidsListViewItem() }
    }
}
