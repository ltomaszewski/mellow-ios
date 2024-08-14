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
    private let accessQueue = DispatchQueue(label: "com.databasestore.queue")
    
    func add(session: SleepSession) {
        accessQueue.sync {
            sleepSessions.append(session)
        }
    }
    
    func remove(session: SleepSession) {
        accessQueue.sync {
            sleepSessions.removeAll(where: { $0.id == session.id })
        }
    }
}
