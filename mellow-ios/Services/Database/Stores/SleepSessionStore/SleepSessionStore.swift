//
//  SleepSessionStore.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 20/10/2024.
//

import Foundation
import SwiftData
import Combine

// TODO: Store should be renamed to repository
struct SleepSessionStore: SleepSessionStoreProtocol {
    func rawLoad(for kid: Kid, context: ModelContext) throws -> [SleepSession] {
        let kidUUID = kid.id
        if let updatedKid = try Kid.query(
            predicate: #Predicate { kidToCompare in
                kidToCompare.id == kidUUID
            },
            sortBy: [],
            context: context
        ).first {
            return updatedKid.sleepSessions
        } else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Kid not found"])
        }
    }

    func add(for kid: Kid, session: SleepSession, context: ModelContext) throws {
        try SleepSession.save(session, context: context)
        try Kid.update(id: kid.id, updateClosure: { $0.addSleepSession(session) }, context: context)
    }

    func replace(for kid: Kid, sessionId: String, newSession: SleepSession, context: ModelContext) throws {
        try SleepSession.update(id: sessionId, updateClosure: { currentSession in
            currentSession.type = newSession.type
            currentSession.startDate = newSession.startDate
            currentSession.endDate = newSession.endDate
        }, context: context)
    }

    // TODO: Extend SwiftDataCRUD with simple fetch by id
    func delete(for kid: Kid, sessionId: String, context: ModelContext) throws {
        if let sessionToDelete = try SleepSession.query(
            predicate: #Predicate { session in
                session.id == sessionId
            },
            sortBy: [],
            context: context
        ).first {
            try SleepSession.delete(sessionToDelete, context: context)
            try Kid.update(id: kid.id, updateClosure: { $0.removeSleepSession(sessionToDelete) }, context: context)
        } else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "SleepSession not found in local array"])
        }
    }

    func removeAll(for kid: Kid, context: ModelContext) throws {
        let kidUUID = kid.id
        if let updatedKid = try Kid.query(
            predicate: #Predicate { kidToCompare in
                kidToCompare.id == kidUUID
            },
            sortBy: [],
            context: context
        ).first {
            let sessions = updatedKid.sleepSessions
            for session in sessions {
                try SleepSession.delete(session, context: context)
            }
            try Kid.update(id: kid.id, updateClosure: { $0.sleepSessions.removeAll() }, context: context)
        } else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Kid not found"])
        }
    }
}
