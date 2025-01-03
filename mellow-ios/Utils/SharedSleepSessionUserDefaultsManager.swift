//
//  UserDefaultsManager.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 03/01/2025.
//

import Foundation

struct SharedSleepSessionData: Codable {
    let name: String
    let startDate: Date
    let expectedEndDate: Date
    let type: String
    
    init(name: String, startDate: Date, expectedEndDate: Date, type: String) {
        self.name = name
        self.startDate = startDate
        self.expectedEndDate = expectedEndDate
        self.type = type
    }
}

struct SharedSleepSessionUserDefaultsManager {
    private let sharedDefaults: UserDefaults
    private let suiteName = "group.com.growgenie.mellow-ios.shared"
    private let sleepSessionKey = "inProgressSleepSession"

    init() {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("Could not create UserDefaults with suite name \(suiteName)")
        }
        self.sharedDefaults = defaults
    }

    // Save a shared sleep session
    func saveSharedSleepSession(_ session: SharedSleepSessionData) {
        do {
            let data = try JSONEncoder().encode(session)
            sharedDefaults.set(data, forKey: sleepSessionKey)
        } catch {
            print("Failed to save shared sleep session: \(error)")
        }
    }

    // Load a shared sleep session
    func loadSharedSleepSession() -> SharedSleepSessionData? {
        guard let data = sharedDefaults.data(forKey: sleepSessionKey) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(SharedSleepSessionData.self, from: data)
        } catch {
            print("Failed to decode shared sleep session: \(error)")
            return nil
        }
    }
    
    // Clear shared sleep session data
    func clearSharedSleepSession() {
        sharedDefaults.removeObject(forKey: sleepSessionKey)
    }
}
