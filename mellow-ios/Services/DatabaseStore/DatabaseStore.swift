//
//  DataStore.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 14/08/2024.
//

import Foundation
import SwiftData
import Combine

class DatabaseStore: ObservableObject {
    @Published var kids: [Kid] = []
    @Published var sleepSession: [SleepSession] = []
    @Published var hoursTracked = 0
    @Published var dayStreak = 0
    
    func addKid(name: String, age: String, context: ModelContext) {
        let newKid = Kid(name: name, age: age)
        context.insert(newKid)
        kids.append(newKid)
        saveContext(context: context)
    }
    
    func loadKids(context: ModelContext) {
        self.kids = try! context.fetch(FetchDescriptor<Kid>())
        updateProperties(context: context)
    }
    
    func removeKid(_ kid: Kid, context: ModelContext) {
        if let index = kids.firstIndex(where: { $0.id == kid.id }) {
            context.delete(kid)
            kids.remove(at: index)
            saveContext(context: context)
        }
    }
    
    func addSleepSession(session: SleepSession, context: ModelContext) {
        guard let kid = kids.first else { fatalError("Kid has to be created at this point") }
        try! SleepSession.save(session, context: context)
        try! Kid.update(id: kid.id,
                        updateClosure: { $0.addSleepSession(session) },
                        context: context)
        updateProperties(context: context)
    }
    
    func replaceSleepSession(sessionId: UUID, newSession: SleepSession, context: ModelContext) {
        try! SleepSession.update(id: sessionId,
                                 updateClosure: { currentSleepSession in
            currentSleepSession.startDate = newSession.startDate
            currentSleepSession.endDate = newSession.endDate
            currentSleepSession.type = newSession.type
        },
                                 context: context)
        
        updateProperties(context: context)
    }
    
    func deleteSleepSession(id: UUID, context: ModelContext) {
        let session = try! SleepSession.query(predicate: #Predicate { $0.id == id }, sortBy: [], context: context).first!
        try! SleepSession.delete(session, context: context)
        updateProperties(context: context)
    }
    
    func hasSession(on date: Date, context: ModelContext) -> Bool {
        sleepSession.hasSession(on: date)
    }
    
    private func saveContext(context: ModelContext) {
        do {
            try context.save()
        } catch {
            fatalError("Failed to insert new item: \(error)")
        }
    }
    
    private func updateProperties(context: ModelContext) {
        self.sleepSession = try! SleepSession.query(sortBy: [],
                                                    context: context)
        hoursTracked = Int(sleepSession.totalHours())
        dayStreak = sleepSession.numberOfDaysWithAtLeastOneSession()
    }
}

private extension Array where Element == SleepSession {
    func hasSession(on date: Date) -> Bool {
        let calendar = Calendar.current
        
        for session in self {
            let sessionDayComponents = calendar.dateComponents([.day, .month, .year], from: session.startDate)
            let givenDayComponents = calendar.dateComponents([.day, .month, .year], from: date)
            
            if sessionDayComponents == givenDayComponents {
                return true
            }
        }
        
        return false
    }
    func totalHours() -> Double {
        return self.reduce(0) { total, session in
            let duration = session.endDate.timeIntervalSince(session.startDate)
            return total + (duration / 3600) // convert seconds to hours
        }
    }
    
    func numberOfDaysWithAtLeastOneSession() -> Int {
        let calendar = Calendar.current
        var uniqueDays = Set<DateComponents>()
        
        for session in self {
            let dayComponents = calendar.dateComponents([.year, .month, .day], from: session.startDate)
            uniqueDays.insert(dayComponents)
        }
        return uniqueDays.count
    }
}
