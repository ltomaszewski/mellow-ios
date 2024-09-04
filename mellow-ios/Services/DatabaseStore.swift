//
//  DataStore.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 14/08/2024.
//

import Foundation
import Combine

class DatabaseStore: ObservableObject {
    @Published var sleepSessions: [SleepSession] = []
    private var internalIndex: [String: SleepSession] = [:]
    
    private let accessQueue = DispatchQueue(label: "com.databasestore.queue")
    
    func add(session: SleepSession) {
        accessQueue.sync {
            internalIndex[session.id] = session
            updateSleepSessionsArray()
        }
    }
    
    func replace(id: String, newSession: SleepSession) {
        accessQueue.sync {
            internalIndex.removeValue(forKey: id)
            internalIndex[newSession.id] = newSession
            updateSleepSessionsArray()
        }
    }
    
    func remove(id: String) {
        accessQueue.sync {
            internalIndex.removeValue(forKey: id)
            updateSleepSessionsArray()
        }
    }
    
    private func updateSleepSessionsArray() {
        sleepSessions = Array(internalIndex.values)
    }
}
