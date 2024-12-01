//
//  DatabaseService.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 20/10/2024.
//

import Foundation
import SwiftData
import Combine

class DatabaseService: ObservableObject {
    @Published var hoursTracked: Int = 0
    @Published var dayStreak: Int = 0
    
    let currentKid = CurrentValueSubject<Kid?, Never>(nil)
    var sleepSessions: AnyPublisher<[SleepSession], Never> {
        sleepSessionStore.sleepSessions.eraseToAnyPublisher()
    }
    
    private let kidsStore = KidsStore()
    private let sleepSessionStore = SleepSessionStore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        sleepSessionStore.hoursTracked
            .receive(on: DispatchQueue.main)
            .assign(to: \.hoursTracked, on: self)
            .store(in: &cancellables)
        
        sleepSessionStore.dayStreak
            .receive(on: DispatchQueue.main)
            .assign(to: \.dayStreak, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Kids Management
    
    func loadKids(context: ModelContext) -> [Kid] {
        do {
            let result = try kidsStore.load(context: context)
            if let kid = result.first {
                selectKid(kid, context: context)
            }
            return result
        } catch {
            print("Failed to load kids: \(error)")
        }
        return []
    }
    
    func addKid(name: String,
                dateOfBirth: Date,
                sleepTime: Date,
                wakeTime: Date,
                context: ModelContext) throws -> Kid {
        // Create a new Kid instance
        let newKid = Kid(name: name, dateOfBirth: dateOfBirth, sleepTime: sleepTime, wakeTime: wakeTime)
        
        // Calculate last night's sleep session dates
        let calendar = Calendar.current
        let now = Date()
        
        // Helper function to create a Date with specific hour and minute on a given day
        func createDate(hour: Int, minute: Int, relativeTo baseDate: Date) -> Date {
            var components = calendar.dateComponents([.year, .month, .day], from: baseDate)
            components.hour = hour
            components.minute = minute
            components.second = 0
            return calendar.date(from: components)!
        }
        
        // Determine if sleepTime is earlier than wakeTime to decide if sleep spans overnight
        let sleepComponents = calendar.dateComponents([.hour, .minute], from: sleepTime)
        let wakeComponents = calendar.dateComponents([.hour, .minute], from: wakeTime)
        
        // Create sleepDate and wakeDate
        var sleepDate: Date
        var wakeDate: Date
        
        if let sleepHour = sleepComponents.hour, let sleepMinute = sleepComponents.minute,
           let wakeHour = wakeComponents.hour, let wakeMinute = wakeComponents.minute {
            
            // Create sleepDate as yesterday's date with sleepTime
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: now) {
                sleepDate = createDate(hour: sleepHour, minute: sleepMinute, relativeTo: yesterday)
            } else {
                // Fallback to sleepTime on the current day if date calculation fails
                sleepDate = createDate(hour: sleepHour, minute: sleepMinute, relativeTo: now)
            }
            
            // Create wakeDate as today's date with wakeTime
            wakeDate = createDate(hour: wakeHour, minute: wakeMinute, relativeTo: now)
            
            // If wakeDate is earlier than sleepDate, assume wakeDate is the next day
            if wakeDate <= sleepDate {
                wakeDate = calendar.date(byAdding: .day, value: 1, to: wakeDate)!
            }
        } else {
            // Fallback dates in case components are missing
            sleepDate = now
            wakeDate = now
        }
        
        // Create a new SleepSession for last night's sleep
        let sleepSession = SleepSession(startDate: sleepDate, endDate: wakeDate, type: "Night Sleep")
        
        // Associate the SleepSession with the Kid
        newKid.addSleepSession(sleepSession)
        
        // Save the SleepSession first (if it's a separate entity)
        try SleepSession.save(sleepSession, context: context)
        
        // Save the Kid to the context
        try Kid.save(newKid, context: context)
        
        selectKid(newKid, context: context)

        return newKid
    }
    
    func removeKid(_ kid: Kid, context: ModelContext) {
        do {
            try kidsStore.remove(kid, context: context)
            if currentKid.value?.id == kid.id {
                if let firstKid = try kidsStore.load(context: context).first {
                    selectKid(firstKid, context: context)
                } else {
                    currentKid.send(nil)
                    sleepSessionStore.reset()
                }
            }
        } catch {
            print("Failed to remove kid: \(error)")
        }
    }
    
    func selectKid(_ kid: Kid, context: ModelContext) {
        currentKid.send(kid)
        loadSleepSessions(for: kid, context: context)
    }
    
    func selectKid(id kidId: String, context: ModelContext) throws {
        if let updatedKid = try Kid.query(
            predicate: #Predicate { kidToCompare in
                kidToCompare.id == kidId
            },
            sortBy: [],
            context: context
        ).first {
            selectKid(updatedKid, context: context)
        } else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Kid not found"])
        }
    }
    
    func updateKid(kid: Kid, name: String, dateOfBirth: Date, context: ModelContext) {
        do {
            try kidsStore.update(kid: kid, name: name, dateOfBirth: dateOfBirth, context: context)
            if currentKid.value?.id == kid.id {
                selectKid(kid, context: context) // Refresh the current kid
            }
        } catch {
            print("Failed to update kid: \(error)")
        }
    }
    
    // MARK: - Sleep Sessions Management
    
    private func loadSleepSessions(for kid: Kid, context: ModelContext) {
        do {
            try sleepSessionStore.load(for: kid, context: context)
        } catch {
            print("Failed to load sleep sessions: \(error)")
        }
    }
    
    func addSleepSession(session: SleepSession, context: ModelContext) {
        guard let kid = currentKid.value else {
            print("No kid selected.")
            return
        }
        do {
            try sleepSessionStore.add(for: kid, session: session, context: context)
        } catch {
            print("Failed to add sleep session: \(error)")
        }
    }
    
    func replaceSleepSession(sessionId: String, with newSession: SleepSession, context: ModelContext) {
        guard let kid = currentKid.value else {
            print("No kid selected.")
            return
        }
        do {
            try sleepSessionStore.replace(for: kid, sessionId: sessionId, newSession: newSession, context: context)
        } catch {
            print("Failed to replace sleep session: \(error)")
        }
    }
    
    func deleteSleepSession(sessionId: String, context: ModelContext) {
        guard let kid = currentKid.value else {
            print("No kid selected.")
            return
        }
        do {
            try sleepSessionStore.delete(for: kid, sessionId: sessionId, context: context)
        } catch {
            print("Failed to delete sleep session: \(error)")
        }
    }
    
    func hasSession(on date: Date) -> Bool {
        return sleepSessionStore.hasSession(on: date)
    }
    
    // MARK: - Remove All Data
    
    func removeAllData(context: ModelContext) {
        do {
            try kidsStore.removeAll(context: context)
            currentKid.send(nil)
            sleepSessionStore.reset()
            print("All data removed successfully.")
        } catch {
            print("Failed to remove all data: \(error)")
        }
    }
}
