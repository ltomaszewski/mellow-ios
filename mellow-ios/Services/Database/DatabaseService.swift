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
    private let kidsStore = KidsStore()
    private let sleepSessionStore = SleepSessionStore()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Kids Management
    func loadKids(context: ModelContext) -> [Kid] {
        do {
            let result = try kidsStore.load(context: context)
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
                
        return newKid
    }
    
    func updateKid(kid: Kid, name: String, dateOfBirth: Date, context: ModelContext) {
        do {
            try kidsStore.update(kid: kid, name: name, dateOfBirth: dateOfBirth, context: context)
        } catch {
            print("Failed to update kid: \(error)")
        }
    }
    
    func updateKid(kidId: String, name: String, dateOfBirth: Date, context: ModelContext) -> Kid {
        do {
            guard let kidToUpdate = try Kid.query(
                predicate: #Predicate { kidToCompare in
                    kidToCompare.id == kidId
                },
                sortBy: [],
                context: context
            ).first else { fatalError("Kid not found") }
            
            try kidsStore.update(kid: kidToUpdate, name: name, dateOfBirth: dateOfBirth, context: context)
            return kidToUpdate
            
        } catch {
            fatalError("Failed to update kid: \(error)")
        }
    }
    
    // MARK: - Sleep Sessions Management
    
    func rawLoadSleepSessions(for kid: Kid, context: ModelContext) -> [SleepSession] {
        do {
            return try sleepSessionStore.rawLoad(for: kid, context: context)
        } catch {
            print("Failed to load sleep sessions: \(error)")
        }
        return []
    }
    
    func addSleepSession(session: SleepSession, kid: Kid? = nil, context: ModelContext) {
        guard let kid else {
            print("No kid selected.")
            return
        }
        do {
            try sleepSessionStore.add(for: kid, session: session, context: context)
        } catch {
            print("Failed to add sleep session: \(error)")
        }
    }
    
    func replaceSleepSession(sessionId: String, with newSession: SleepSession, for kid: Kid, context: ModelContext) {
        do {
            try sleepSessionStore.replace(for: kid, sessionId: sessionId, newSession: newSession, context: context)
        } catch {
            print("Failed to replace sleep session: \(error)")
        }
    }
    
    func deleteSleepSession(sessionId: String, for kid: Kid, context: ModelContext) {
        do {
            try sleepSessionStore.delete(for: kid, sessionId: sessionId, context: context)
        } catch {
            print("Failed to delete sleep session: \(error)")
        }
    }
    
    // MARK: - Remove All Data
    
    func removeAllData(context: ModelContext) {
        do {
            try kidsStore.removeAll(context: context)
            print("All data removed successfully.")
        } catch {
            print("Failed to remove all data: \(error)")
        }
    }
}
