//
//  SleepSessionStoreProtocol.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 20/10/2024.
//

import Foundation
import SwiftData
import Combine

protocol SleepSessionStoreProtocol {
    var sleepSessions: CurrentValueSubject<[SleepSession], Never> { get }
    var hoursTracked: CurrentValueSubject<Int, Never> { get }
    var dayStreak: CurrentValueSubject<Int, Never> { get }

    func load(for kid: Kid, context: ModelContext) throws
    func add(for kid: Kid, session: SleepSession, context: ModelContext) throws
    func replace(for kid: Kid, sessionId: String, newSession: SleepSession, context: ModelContext) throws
    func delete(for kid: Kid, sessionId: String, context: ModelContext) throws
    func hasSession(on date: Date) -> Bool
    func removeAll(for kid: Kid, context: ModelContext) throws // New method
}
