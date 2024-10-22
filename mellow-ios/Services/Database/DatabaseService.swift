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
    @Published var kids: [Kid] = []
    @Published var sleepSessions: [SleepSession] = []
    @Published var hoursTracked: Int = 0
    @Published var dayStreak: Int = 0

    private let kidsStore = KidsStore()
    private let sleepSessionStore = SleepSessionStore()
    private var cancellables = Set<AnyCancellable>()

    // Keeps track of the currently selected kid
    private var currentKid: Kid?

    init() {
        setupSubscriptions()
        // No context available here, so we can't load kids yet
    }

    private func setupSubscriptions() {
        // Subscribe to kidsStore's kids property
        kidsStore.kids
            .receive(on: DispatchQueue.main)
            .assign(to: \.kids, on: self)
            .store(in: &cancellables)

        // Subscribe to sleepSessionStore's published properties
        sleepSessionStore.sleepSessions
            .receive(on: DispatchQueue.main)
            .assign(to: \.sleepSessions, on: self)
            .store(in: &cancellables)

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

    func loadKids(context: ModelContext) {
        do {
            let result = try kidsStore.loadKids(context: context)
            if let kid = result.first {
                // If this is the first kid, select it
                selectKid(kid, context: context)
            }
        } catch {
            print("Failed to load kids: \(error)")
        }
    }

    func addKid(name: String, dateOfBirth: Date, context: ModelContext) {
        do {
            let newKid = try kidsStore.addKid(name: name, dateOfBirth: dateOfBirth, context: context)
            selectKid(newKid, context: context)
        } catch {
            print("Failed to add kid: \(error)")
        }
    }

    func removeKid(_ kid: Kid, context: ModelContext) {
        do {
            try kidsStore.removeKid(kid, context: context)
            if currentKid?.id == kid.id {
                // If the removed kid was selected, select another kid or clear selection
                if let firstKid = kids.first {
                    selectKid(firstKid, context: context)
                } else {
                    currentKid = nil
                    // Clear sleep sessions
                    sleepSessions = []
                    hoursTracked = 0
                    dayStreak = 0
                }
            }
        } catch {
            print("Failed to remove kid: \(error)")
        }
    }

    func selectKid(_ kid: Kid, context: ModelContext) {
        currentKid = kid
        loadSleepSessions(for: kid, context: context)
    }

    // MARK: - Sleep Sessions Management

    private func loadSleepSessions(for kid: Kid, context: ModelContext) {
        do {
            try sleepSessionStore.loadSleepSessions(for: kid, context: context)
        } catch {
            print("Failed to load sleep sessions: \(error)")
        }
    }

    func addSleepSession(session: SleepSession, context: ModelContext) {
        guard let kid = currentKid else {
            print("No kid selected.")
            return
        }
        do {
            try sleepSessionStore.addSleepSession(for: kid, session: session, context: context)
        } catch {
            print("Failed to add sleep session: \(error)")
        }
    }

    func replaceSleepSession(sessionId: String, with newSession: SleepSession, context: ModelContext) {
        guard let kid = currentKid else {
            print("No kid selected.")
            return
        }
        do {
            try sleepSessionStore.replaceSleepSession(for: kid, sessionId: sessionId, newSession: newSession, context: context)
        } catch {
            print("Failed to replace sleep session: \(error)")
        }
    }

    func deleteSleepSession(sessionId: String, context: ModelContext) {
        guard let kid = currentKid else {
            print("No kid selected.")
            return
        }
        do {
            try sleepSessionStore.deleteSleepSession(for: kid, sessionId: sessionId, context: context)
        } catch {
            print("Failed to delete sleep session: \(error)")
        }
    }

    func hasSession(on date: Date) -> Bool {
        return sleepSessionStore.hasSession(on: date)
    }
}
