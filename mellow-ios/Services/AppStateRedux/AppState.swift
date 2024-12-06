//
//  RAppState.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 01/12/2024.
//

import Foundation
import SwiftData

struct AppState {
    var onboardingState: OnboardingState
    var selectedKid: Kid?
    var selectedDate: Date?
    var hoursTracked: Int = 0
    var dayStreak: Int = 0
    var currentViewState: CurrentViewState = .intro
    var sleepSessions: [SleepSessionViewRepresentation] = []
    var sleepSessionInProgress: SleepSessionViewRepresentation?
    
    init(onboardingState: OnboardingState = .init(),
         selectedKid: Kid? = nil,
         selectedDate: Date = .now.adjustToMidday()) {
        self.onboardingState = onboardingState
        self.selectedKid = selectedKid
        self.selectedDate = selectedDate
    }
}

extension AppState {
    enum CurrentViewState {
        case intro
        case onboarding
        case root
    }
}

// All possible actions for AppState
extension AppState {
    enum Action {
        case load(ModelContext)
        case openAddKidOnboarding
        case onboarding(OnboardingState.Action)
        case setSelectedKid(Kid, ModelContext)
        case setSelectedDate(Date)
        case kidOperation(CRUDOperation, Kid, ModelContext)
        case sleepSessionOperation(CRUDOperation, SleepSession?, ModelContext)
        case startSleepSessionInProgress(ModelContext)
        case endSleepSessionInProgress(ModelContext)
        case error(Error)
        case resetError
        case refreshSchedule
    }
    
    enum CRUDOperation {
        case create
        case update(String)
        case delete(String)
    }
}

// Action execution
extension AppState {
    //TODO: Split to smaller reducers
    struct Reducer: ReducerProtocol {
        private let onboardingReducer: OnboardingState.Reducer
        private let databaseService: DatabaseService
        private let sleepManager: SleepManager = .init()
        
        private let isDebugMode: Bool

        init(onboardingReducer: OnboardingState.Reducer, databaseService: DatabaseService, isDebugMode: Bool = true) {
            self.onboardingReducer = onboardingReducer
            self.databaseService = databaseService
            self.isDebugMode = isDebugMode
        }

        func reduce(state: inout AppState, action: AppState.Action) {
            switch action {
            case .load(let context):
                handleLoadAction(state: &state, context: context)
            case .openAddKidOnboarding:
                handleOpenAddKidOnboarding(state: &state)
            case .onboarding(let action):
                handleOnboardingAction(state: &state, action: action)
            case .setSelectedKid(let kid, let modelContext):
                state.selectedKid = kid
                updateSleepSessionState(state: &state, kid: kid, context: modelContext)
            case .setSelectedDate(let date):
                state.selectedDate = date
                handleRefreshSchedule(state: &state)
            case .kidOperation(let operation, let kid, let modelContext):
                handleKidOperation(state: &state, operation: operation, kid: kid, context: modelContext)
            case .sleepSessionOperation(let operation, let sleepSession, let modelContext):
                handleSleepSessionOperation(state: &state, operation: operation, sleepSession: sleepSession, context: modelContext)
            case .startSleepSessionInProgress(let modelContext):
                handleSleepSessionOperation(state: &state,
                                            operation: .create,
                                            sleepSession: .init(startDate: .now, endDate: nil, type: SleepSessionType.nap.rawValue),
                                            context: modelContext)
            case .endSleepSessionInProgress(let modelContext):
                handleEndSleepSessionInProgress(state: &state, context: modelContext)
            case .refreshSchedule:
                handleRefreshSchedule(state: &state)
            default:
                fatalError("Unsupported action")
            }

            debugPrint(item: action)
            debugPrint(state: state)
        }

        // MARK: - Helper Methods

        private func handleLoadAction(state: inout AppState, context: ModelContext) {
            let kids = databaseService.loadKids(context: context)
            state.currentViewState = kids.isEmpty ? .intro : .root
            if let kid = kids.first {
                state.selectedKid = kid
                updateSleepSessionState(state: &state, kid: kid, context: context)
            }
        }

        private func handleOpenAddKidOnboarding(state: inout AppState) {
            OnboardingState.removeFromUserDefaults()
            state.onboardingState = .init()
            state.currentViewState = .onboarding
        }

        private func handleOnboardingAction(state: inout AppState, action: OnboardingState.Action) {
            onboardingReducer.reduce(state: &state.onboardingState, action: action)
        }

        private func handleKidOperation(state: inout AppState, operation: CRUDOperation, kid: Kid, context: ModelContext) {
            switch operation {
            case .create:
                createKid(state: &state, kid: kid, context: context)
            case .update(let id):
                updateKid(state: &state, kid: kid, id: id, context: context)
            case .delete:
                fatalError("Delete kid is not supported")
            }
        }

        private func handleSleepSessionOperation(state: inout AppState, operation: CRUDOperation, sleepSession: SleepSession?, context: ModelContext) {
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

        private func handleEndSleepSessionInProgress(state: inout AppState, context: ModelContext) {
            guard let selectedKid = state.selectedKid else {
                fatalError("SelectedKid is unavailable")
            }
            
            guard let sleepSessionInProgress = state.sleepSessionInProgress else {
                return
            }
            // Create a new SleepSession object with the updated endDate
            let updatedSession = sleepSessionInProgress.toSleepSession()
            updatedSession.endDate = Date()

            // Update the session in the database
            databaseService.replaceSleepSession(sessionId: updatedSession.id, with: updatedSession, for: selectedKid, context: context)

            // Update state
            if let currentKid = state.selectedKid {
                updateSleepSessionState(state: &state, kid: currentKid, context: context)
            }
        }

        // MARK: - Kid Operations

        private func createKid(state: inout AppState, kid: Kid, context: ModelContext) {
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
                updateSleepSessionState(state: &state, kid: newKid, context: context)
            } catch {
                fatalError("Error saving kid in the database: \(error)")
            }
        }

        private func updateKid(state: inout AppState, kid: Kid, id: String, context: ModelContext) {
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

        private func createSleepSession(state: inout AppState, sleepSession: SleepSession, context: ModelContext) {
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

        private func updateSleepSession(state: inout AppState, sleepSession: SleepSession, id: String, context: ModelContext) {
            guard let currentKid = state.selectedKid else {
                print("No selected kid for updating a sleep session.")
                return
            }
            databaseService.replaceSleepSession(sessionId: id, with: sleepSession, for: currentKid, context: context)
            updateSleepSessionState(state: &state, kid: currentKid, context: context)
        }

        private func deleteSleepSession(state: inout AppState, id: String, context: ModelContext) {
            guard let currentKid = state.selectedKid else {
                print("No selected kid for deleting a sleep session.")
                return
            }
            databaseService.deleteSleepSession(sessionId: id, for: currentKid, context: context)
            updateSleepSessionState(state: &state, kid: currentKid, context: context)
        }

        private func updateSleepSessionState(state: inout AppState, kid: Kid, context: ModelContext) {
            let sessions = databaseService.rawLoadSleepSessions(for: kid, context: context)
            state.sleepSessions = sessions.map { $0.toViewRepresentation() }
            state.sleepSessionInProgress = state.sleepSessions.first(where: { $0.isInProgress })
            state.hoursTracked = Int(sessions.totalHours())
            state.dayStreak = sessions.numberOfDaysWithAtLeastOneSession()
            handleRefreshSchedule(state: &state)
        }

        private func handleRefreshSchedule(state: inout AppState) {
            guard let currentKid = state.selectedKid else {
                print("No selected kid to refresh schedule.")
                return
            }

            let ageInMonths = currentKid.ageInMonths
            guard let selectedDate = state.selectedDate else {
                print("No selected date to refresh schedule.")
                return
            }

            // Calculate the day before and the day after the selected date
            let calendar = Calendar.current
            guard let dayBeforeBefore = calendar.date(byAdding: .day, value: -2, to: selectedDate),
                  let dayBefore = calendar.date(byAdding: .day, value: -1, to: selectedDate),
                  let dayAfter = calendar.date(byAdding: .day, value: 1, to: selectedDate),
                  let dayAfterAfter = calendar.date(byAdding: .day, value: 2, to: selectedDate) else {
                print("Failed to calculate adjacent dates.")
                return
            }

            // List of dates for which to generate schedules
            let datesToGenerate = [dayBeforeBefore, dayBefore, selectedDate, dayAfter, dayAfterAfter]

            // Generate new sleep schedules for each date
            var allNewSleepSessions: [SleepSessionViewRepresentation] = []

            for date in datesToGenerate {
                // Find the wake-up time from the night sleep session ending on this date
                let wakeUpTime = state.sleepSessions.nightSleepEnding(on: date)?.endDate

                // Generate sleep schedule for this date
                guard let newSchedule = sleepManager.getSleepSchedule(for: ageInMonths, wakeUpTime: wakeUpTime, baseDate: date) else {
                    print("Failed to generate sleep schedule for date: \(date)")
                    continue
                }

                let newSleepSessions = newSchedule.toViewRepresentations()
                allNewSleepSessions.append(contentsOf: newSleepSessions)
            }

            // Extract existing saved sleep sessions (not scheduled)
            let savedSleepSessions = state.sleepSessions.filter { !$0.isScheduled }

            // Function to check if two date ranges overlap
            func sessionsOverlap(_ session1: SleepSessionViewRepresentation, _ session2: SleepSessionViewRepresentation) -> Bool {
                guard let session1EndDate = session1.endDate, let session2EndDate = session2.endDate else { return false }
                return session1.startDate < session2EndDate && session2.startDate < session1EndDate
            }

            // Filter out new scheduled sessions that overlap with any saved session
            let filteredNewSleepSessions = allNewSleepSessions.filter { newSession in
                !savedSleepSessions.contains { savedSession in
                    sessionsOverlap(newSession, savedSession)
                }
            }

            // Merge with existing sleep sessions
            var mergedSleepSessions = state.sleepSessions

            // Remove existing scheduled sessions for the three dates to prevent duplicates
            mergedSleepSessions.removeAll { session in
                session.isScheduled && datesToGenerate.contains(where: { calendar.isDate(session.startDate, inSameDayAs: $0) })
            }

            // Add the filtered new scheduled sessions
            mergedSleepSessions.append(contentsOf: filteredNewSleepSessions)

            // Sort the sleep sessions by start date
            mergedSleepSessions.sort { $0.startDate < $1.startDate }

            // Update the state
            state.sleepSessions = mergedSleepSessions
        }
        
        // MARK: - Debug Mode
        private func debugPrint(state: AppState) {
            guard isDebugMode else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timestamp = formatter.string(from: Date())
            print("[\(timestamp)] Current State: \(state)")
        }
        
        // MARK: - Debug Mode
        private func debugPrint(item: CustomStringConvertible) {
            guard isDebugMode else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timestamp = formatter.string(from: Date())
            print("[\(timestamp)] Output: \(item)")
        }
    }
}

// RAppState Store
extension AppState {
    class Store: ObservableObject {
        @Published private(set) var state: AppState
        private let reducer: Reducer
        
        init(state: AppState = .init(), databaseService: DatabaseService) {
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
extension AppState.Store {
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
            get: { self.state.onboardingState.sleepTime ?? .now.evening() },
            set: { [weak self] date in self?.dispatch(.onboarding(.setSleepTime(date))) }
        )
    }
    
    /// Binding for "When Nina usually wakes up?"
    var wakeTimeBinding: Binding<Date?> {
        .init(
            get: { self.state.onboardingState.wakeTime ?? .now.morning() },
            set: { [weak self] date in self?.dispatch(.onboarding(.setWakeTime(date))) }
        )
    }
    
    var sleepSessionInProgressBinding: Binding<SleepSessionViewRepresentation?> {
        .init(get: { self.state.sleepSessionInProgress }, set: { _ in })
    }
}
