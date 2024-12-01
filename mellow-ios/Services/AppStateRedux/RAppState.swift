//
//  RAppState.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 01/12/2024.
//

import Foundation
import SwiftData

struct RAppState {
    var onboardingState: ROnboardingState
    var selectedKid: Kid?
    var selectedDate: Date?
    var hoursTracked: Int = 0
    var dayStreak: Int = 0
    var currentViewState: CurrentViewState = .intro
    var sleepSessions: [SleepSessionViewRepresentation] = []
    var sleepSessionInProgress: SleepSessionViewRepresentation?
    
    init(onboardingState: ROnboardingState = .init(),
         selectedKid: Kid? = nil,
         selectedDate: Date? = nil) {
        self.onboardingState = onboardingState
        self.selectedKid = selectedKid
        self.selectedDate = selectedDate
    }
}

extension RAppState {
    enum CurrentViewState {
        case intro
        case onboarding
        case root
    }
}

// All possible actions for AppState
extension RAppState {
    enum Action {
        case load(ModelContext)
        case openAddKidOnboarding
        case onboarding(ROnboardingState.Action)
        case setSelectedKid(Kid)
        case setSelectedDate(Date)
        case kidOperation(CRUDOperation, Kid, ModelContext)
        case sleepSessionOperation(CRUDOperation, SleepSession?, ModelContext)
        case endSleepSessionInProgress(ModelContext)
        case error(Error)
        case resetError
    }
    
    enum CRUDOperation {
        case create
        case update(String)
        case delete(String)
    }
}

// Action execution
extension RAppState {
    struct Reducer: ReducerProtocol {
        private let onboardingReducer: ROnboardingState.Reducer
        private weak var databaseService: DatabaseService?
        private let isDebugMode: Bool

        init(onboardingReducer: ROnboardingState.Reducer, databaseService: DatabaseService, isDebugMode: Bool = true) {
            self.onboardingReducer = onboardingReducer
            self.databaseService = databaseService
            self.isDebugMode = isDebugMode
        }

        func reduce(state: inout RAppState, action: RAppState.Action) {
            switch action {
            case .load(let context):
                handleLoadAction(state: &state, context: context)
            case .openAddKidOnboarding:
                handleOpenAddKidOnboarding(state: &state)
            case .onboarding(let action):
                handleOnboardingAction(state: &state, action: action)
            case .setSelectedKid(let kid):
                state.selectedKid = kid
            case .setSelectedDate(let date):
                state.selectedDate = date
            case .kidOperation(let operation, let kid, let modelContext):
                handleKidOperation(state: &state, operation: operation, kid: kid, context: modelContext)
            case .sleepSessionOperation(let operation, let sleepSession, let modelContext):
                handleSleepSessionOperation(state: &state, operation: operation, sleepSession: sleepSession, context: modelContext)
            case .endSleepSessionInProgress(let modelContext):
                handleEndSleepSessionInProgress(state: &state, context: modelContext)
            default:
                fatalError("Unsupported action")
            }

            debugPrint(state: state)
        }

        // MARK: - Helper Methods

        private func handleLoadAction(state: inout RAppState, context: ModelContext) {
            guard let databaseService = databaseService else {
                print("DatabaseService is unavailable")
                return
            }
            let kids = databaseService.loadKids(context: context)
            state.currentViewState = kids.isEmpty ? .intro : .root
            if let kid = kids.first {
                state.selectedKid = kid
                updateSleepSessionState(state: &state, kid: kid, context: context)
            }
        }

        private func handleOpenAddKidOnboarding(state: inout RAppState) {
            ROnboardingState.removeFromUserDefaults()
            state.onboardingState = .init()
            state.currentViewState = .onboarding
        }

        private func handleOnboardingAction(state: inout RAppState, action: ROnboardingState.Action) {
            onboardingReducer.reduce(state: &state.onboardingState, action: action)
        }

        private func handleKidOperation(state: inout RAppState, operation: CRUDOperation, kid: Kid, context: ModelContext) {
            switch operation {
            case .create:
                createKid(state: &state, kid: kid, context: context)
            case .update(let id):
                updateKid(state: &state, kid: kid, id: id, context: context)
            case .delete:
                fatalError("Delete kid is not supported")
            }
        }

        private func handleSleepSessionOperation(state: inout RAppState, operation: CRUDOperation, sleepSession: SleepSession?, context: ModelContext) {
            switch operation {
            case .create:
                guard let sleepSession else { fatalError("createSleepSession: sleepSession is nil")}
                createSleepSession(state: &state, sleepSession: sleepSession, context: context)
            case .update(let id):
                guard let sleepSession else { fatalError("createSleepSession: sleepSession is nil")}
                updateSleepSession(state: &state, sleepSession: sleepSession, id: id, context: context)
            case .delete(let id):
                deleteSleepSession(state: &state, id: id, context: context)
            }
        }

        private func handleEndSleepSessionInProgress(state: inout RAppState, context: ModelContext) {
            guard let databaseService = databaseService else {
                print("DatabaseService is unavailable")
                return
            }
            guard let sleepSessionInProgress = state.sleepSessionInProgress else {
                return
            }
            // Create a new SleepSession object with the updated endDate
            var updatedSession = sleepSessionInProgress.toSleepSession()
            updatedSession.endDate = Date()

            // Update the session in the database
            databaseService.replaceSleepSession(sessionId: updatedSession.id, with: updatedSession, context: context)

            // Update state
            if let currentKid = state.selectedKid {
                updateSleepSessionState(state: &state, kid: currentKid, context: context)
            }
        }

        // MARK: - Kid Operations

        private func createKid(state: inout RAppState, kid: Kid, context: ModelContext) {
            guard let databaseService = databaseService else {
                print("DatabaseService is unavailable")
                return
            }
            do {
                let newKid = try databaseService.addKid(
                    name: kid.name,
                    dateOfBirth: kid.dateOfBirth,
                    sleepTime: kid.sleepTime,
                    wakeTime: kid.wakeTime,
                    context: context
                )
                state.selectedKid = newKid
                state.currentViewState = .root
            } catch {
                fatalError("Error saving kid in the database: \(error)")
            }
        }

        private func updateKid(state: inout RAppState, kid: Kid, id: String, context: ModelContext) {
            guard let databaseService = databaseService else {
                print("DatabaseService is unavailable")
                return
            }
            let updatedKid = databaseService.updateKid(
                kidId: id,
                name: kid.name,
                dateOfBirth: kid.dateOfBirth,
                context: context
            )
            if state.selectedKid?.id == id {
                state.selectedKid = updatedKid
            }
        }

        // MARK: - Sleep Session Operations

        private func createSleepSession(state: inout RAppState, sleepSession: SleepSession, context: ModelContext) {
            guard let databaseService = databaseService else {
                print("DatabaseService is unavailable")
                return
            }
            guard let currentKid = state.selectedKid else {
                print("No selected kid for adding a sleep session.")
                return
            }
            let newSession = SleepSession(
                startDate: sleepSession.startDate,
                endDate: sleepSession.endDate,
                type: sleepSession.type
            )
            databaseService.addSleepSession(session: newSession, kid: currentKid, context: context)
            updateSleepSessionState(state: &state, kid: currentKid, context: context)
        }

        private func updateSleepSession(state: inout RAppState, sleepSession: SleepSession, id: String, context: ModelContext) {
            guard let databaseService = databaseService else {
                print("DatabaseService is unavailable")
                return
            }
            guard let currentKid = state.selectedKid else {
                print("No selected kid for updating a sleep session.")
                return
            }
            databaseService.replaceSleepSession(sessionId: id, with: sleepSession, context: context)
            updateSleepSessionState(state: &state, kid: currentKid, context: context)
        }

        private func deleteSleepSession(state: inout RAppState, id: String, context: ModelContext) {
            guard let databaseService = databaseService else {
                print("DatabaseService is unavailable")
                return
            }
            guard let currentKid = state.selectedKid else {
                print("No selected kid for deleting a sleep session.")
                return
            }
            databaseService.deleteSleepSession(sessionId: id, context: context)
            updateSleepSessionState(state: &state, kid: currentKid, context: context)
        }

        private func updateSleepSessionState(state: inout RAppState, kid: Kid, context: ModelContext) {
            guard let databaseService = databaseService else {
                print("DatabaseService is unavailable")
                return
            }
            let sessions = databaseService.rawLoadSleepSessions(for: kid, context: context)
            state.sleepSessions = sessions.map { $0.toViewRepresentation() }
            state.sleepSessionInProgress = state.sleepSessions.first(where: { $0.isInProgress })
            state.hoursTracked = Int(sessions.totalHours())
            state.dayStreak = sessions.numberOfDaysWithAtLeastOneSession()
        }

        // MARK: - Debug Mode

        private func debugPrint(state: RAppState) {
            guard isDebugMode else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timestamp = formatter.string(from: Date())
            print("[\(timestamp)] Current State: \(state)")
        }
    }
}

// RAppState Store
extension RAppState {
    class Store: ObservableObject {
        @Published private(set) var state: RAppState
        private let reducer: Reducer
        
        init(state: RAppState = .init(), databaseService: DatabaseService) {
            self.state = state
            reducer = .init(onboardingReducer: .init(), databaseService: databaseService)
        }
        
        func dispatch(_ action: Action) {
            reducer.reduce(state: &state, action: action)
        }
    }
}


import SwiftUI

// Binding for State and SwiftUI TODO: Export to Swift Macro
extension RAppState.Store {
    var welcomeMessageShownBinding: Binding<Bool> {
        .init(
            get: { self.state.onboardingState.welcomeMessageShown },
            set: { [weak self] _ in self?.dispatch(.onboarding(.welcomeMessageShown)) }
        )
    }
    
    var childNameBinding: Binding<String> {
        .init(
            get: { self.state.onboardingState.childName },
            set: { [weak self] name in self?.dispatch(.onboarding(.setChildName(name))) }
        ) // TODO: Research If weak self is really needed here
    }
    
    var kidAgeBinding: Binding<Date?> {
        .init(
            get: { self.state.onboardingState.kidDateOfBirth },
            set: { [weak self] date in self?.dispatch(.onboarding(.setKidDateOfBirth(date))) }
        )
    }
    
    // **New Bindings for Sleep and Wake Times**
    
    /// Binding for "When Nina usually falls asleep?"
    var sleepTimeBinding: Binding<Date?> {
        .init(
            get: { self.state.onboardingState.sleepTime },
            set: { [weak self] date in self?.dispatch(.onboarding(.setSleepTime(date))) }
        )
    }
    
    /// Binding for "When Nina usually wakes up?"
    var wakeTimeBinding: Binding<Date?> {
        .init(
            get: { self.state.onboardingState.wakeTime },
            set: { [weak self] date in self?.dispatch(.onboarding(.setWakeTime(date))) }
        )
    }
    
    var sleepSessionInProgressBinding: Binding<SleepSessionViewRepresentation?> {
        .init(get: { self.state.sleepSessionInProgress }, set: { _ in })
    }
}
