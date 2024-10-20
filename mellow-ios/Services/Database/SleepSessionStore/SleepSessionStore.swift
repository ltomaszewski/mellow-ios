//
//  SleepSessionStore.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 20/10/2024.
//

import Foundation
import SwiftData
import Combine

struct SleepSessionStore {
    let sleepSessions = CurrentValueSubject<[SleepSession], Never>([])
    let hoursTracked = CurrentValueSubject<Int, Never>(0)
    let dayStreak = CurrentValueSubject<Int, Never>(0)

    func loadSleepSessions(for kid: Kid, context: ModelContext) throws {
        let kidUUID = kid.id
        if let updatedKid = try Kid.query(
            predicate: #Predicate { kidToCompare in
                kidToCompare.id == kidUUID
            },
            sortBy: [],
            context: context
        ).first {
            let sessions = updatedKid.sleepSessions
            sleepSessions.send(sessions)
            updateProperties(sessions: sessions)
        } else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Kid not found"])
        }
    }

    func addSleepSession(for kid: Kid, session: SleepSession, context: ModelContext) throws {
        try SleepSession.save(session, context: context)
        try Kid.update(id: kid.id, updateClosure: { $0.addSleepSession(session) }, context: context)
        
        var updatedSessions = sleepSessions.value
        updatedSessions.append(session)
        sleepSessions.send(updatedSessions)
        updateProperties(sessions: updatedSessions)
    }

    func replaceSleepSession(for kid: Kid, sessionId: String, newSession: SleepSession, context: ModelContext) throws {
        try SleepSession.update(id: sessionId, updateClosure: { currentSession in
            currentSession.type = newSession.type
            currentSession.startDate = newSession.startDate
            currentSession.endDate = newSession.endDate
        }, context: context)

        var updatedSessions = sleepSessions.value
        if let index = updatedSessions.firstIndex(where: { $0.id == sessionId }) {
            updatedSessions[index] = newSession
            sleepSessions.send(updatedSessions)
            updateProperties(sessions: updatedSessions)
        } else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "SleepSession not found in local array"])
        }
    }

    func deleteSleepSession(for kid: Kid, sessionId: String, context: ModelContext) throws {
        var updatedSessions = sleepSessions.value
        if let index = updatedSessions.firstIndex(where: { $0.id == sessionId }) {
            let session = updatedSessions[index]
            try SleepSession.delete(session, context: context)
            try Kid.update(id: kid.id, updateClosure: { $0.removeSleepSession(session) }, context: context)

            updatedSessions.remove(at: index)
            sleepSessions.send(updatedSessions)
            updateProperties(sessions: updatedSessions)
        } else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "SleepSession not found in local array"])
        }
    }

    func hasSession(on date: Date) -> Bool {
        return sleepSessions.value.hasSession(on: date)
    }

    private func updateProperties(sessions: [SleepSession]) {
        let totalHours = Int(sessions.totalHours())
        hoursTracked.send(totalHours)

        let streak = sessions.numberOfDaysWithAtLeastOneSession()
        dayStreak.send(streak)
    }
}
