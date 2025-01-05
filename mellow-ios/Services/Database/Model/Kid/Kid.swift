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
    var id: String = UUID().uuidString // Default value
    var name: String = "Unnamed" // Default value
    var dateOfBirth: Date = Date() // Default value
    var isHim: Bool = true // Default value
    var sleepTime: Date = Date() // Default value
    var wakeTime: Date = Date() // Default value
    var sleepSessions: [SleepSession]? = [] // Optional relationship
    
    init(name: String, dateOfBirth: Date, sleepTime: Date, wakeTime: Date) {
        self.id = UUID().uuidString
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.sleepTime = sleepTime
        self.wakeTime = wakeTime
        self.isHim = true
    }
    
    func addSleepSession(_ session: SleepSession) {
        session.kid = self // Set inverse relationship
        sleepSessions?.append(session)
    }

    func removeSleepSession(_ session: SleepSession) {
        if let index = sleepSessions?.firstIndex(where: { $0.id == session.id }) {
            sleepSessions?.remove(at: index)
            session.kid = nil // Clear inverse relationship
        }
    }

    func replaceSleepSession(id: String, with newSession: SleepSession) {
        if let index = sleepSessions?.firstIndex(where: { $0.id == id }),
            let oldSession = sleepSessions?[index] {
            oldSession.type = newSession.type
            oldSession.startDate = newSession.startDate
            oldSession.endDate = newSession.endDate
            oldSession.kid = nil // Clear old inverse relationship
            newSession.kid = self // Set new inverse relationship
            sleepSessions?[index] = newSession
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
