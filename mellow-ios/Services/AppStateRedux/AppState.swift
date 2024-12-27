//
//  RAppState.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 01/12/2024.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - AppState

struct AppState {
    var onboardingState: OnboardingState
    var selectedKid: Kid?
    var selectedDate: Date?
    var hoursTracked: Int = 0
    var dayStreak: Int = 0
    var currentViewState: CurrentViewState = .intro
    var sleepSessions: [SleepSessionViewRepresentation] = []
    var sleepSessionInProgress: SleepSessionViewRepresentation?
    var appSettings: AppSettings = .init(deviceId: "", kidId: "")
    
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

// MARK: - Actions

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
        case refreshSchedule
        case updateSettings(AppSettings)
        case resetSettings
    }
    
    enum CRUDOperation {
        case create
        case update(String)
        case delete(String)
    }
}

// MARK: - Reducer

extension AppState {
    struct Reducer: ReducerProtocol {
        private let onboardingReducer: OnboardingState.Reducer
        private let databaseService: DatabaseService
        private let settingsManager: SettingsManager
        private let sleepManager: SleepManager = .init()
        
        private let isDebugMode: Bool
        
        init(onboardingReducer: OnboardingState.Reducer,
             databaseService: DatabaseService,
             settingsManager: SettingsManager,
             isDebugMode: Bool = true) {
            self.onboardingReducer = onboardingReducer
            self.databaseService = databaseService
            self.settingsManager = settingsManager
            self.isDebugMode = isDebugMode
        }
        
        func reduce(_ oldState: AppState, action: AppState.Action) -> AppState {
            // Create a mutable copy for us to modify
            var newState = oldState
            
            // Switch on the action and mutate `newState`
            switch action {
            case .load(let context):
                handleLoadAction(state: &newState, context: context)
                
            case .openAddKidOnboarding:
                handleOpenAddKidOnboarding(state: &newState)
                
            case .onboarding(let subAction):
                switch subAction {
                case .close:
                    newState.currentViewState = .root
                default:
                    handleOnboardingAction(state: &newState, action: subAction)
                }
                
            case .setSelectedKid(let kid, let modelContext):
                newState.selectedKid = kid
                updateSleepSessionState(state: &newState, kid: kid, context: modelContext)
                
                var currentSettings = oldState.appSettings
                currentSettings.kidId = kid.id
                newState = self.reduce(newState, action: .updateSettings(currentSettings))
                
            case .setSelectedDate(let date):
                newState.selectedDate = date
                handleRefreshSchedule(state: &newState)
                
            case .kidOperation(let operation, let kid, let modelContext):
                handleKidOperation(state: &newState, operation: operation, kid: kid, context: modelContext)
                
            case .sleepSessionOperation(let operation, let sleepSession, let modelContext):
                handleSleepSessionOperation(state: &newState, operation: operation, sleepSession: sleepSession, context: modelContext)
                
            case .startSleepSessionInProgress(let modelContext):
                handleSleepSessionOperation(
                    state: &newState,
                    operation: .create,
                    sleepSession: .init(startDate: .now, endDate: nil, type: SleepSessionType.nap.rawValue),
                    context: modelContext
                )
                
            case .endSleepSessionInProgress(let modelContext):
                handleEndSleepSessionInProgress(state: &newState, context: modelContext)
                
            case .refreshSchedule:
                handleRefreshSchedule(state: &newState)
                
            case .updateSettings(let newSettings):
                handleUpdateSettings(state: &newState, newSettings: newSettings)
                
            case .resetSettings:
                handleResetSettings(state: &newState)
            }
            
            // Debug prints
            debugPrint(item: action)
            // debugPrint(state: newState)
            
            return newState
        }
        
        // MARK: - AppSettings Actions
        
        private func handleUpdateSettings(state: inout AppState, newSettings: AppSettings) {
            settingsManager.updateSettings { settings in
                settings = newSettings
            }
            state.appSettings = newSettings
        }
        
        private func handleResetSettings(state: inout AppState) {
            settingsManager.reset()
            state.appSettings = settingsManager.getSettings()
        }
        
        // MARK: - Helper Methods
        
        private func handleLoadAction(state: inout AppState, context: ModelContext) {
            state.appSettings = settingsManager.getSettings()
            state.currentViewState = state.appSettings.kidId.isEmpty ? .intro : .root
            
            guard !state.appSettings.kidId.isEmpty else { return }
            let kids = databaseService.loadKids(context: context)
            guard let selectedKid = kids.first(where: { $0.id == state.appSettings.kidId }) else {
                fatalError("App settings invalid, no kid found with id \(state.appSettings.kidId)")
            }
            state.selectedKid = selectedKid
            updateSleepSessionState(state: &state, kid: selectedKid, context: context)
        }
        
        private func handleOpenAddKidOnboarding(state: inout AppState) {
            OnboardingState.removeFromUserDefaults()
            state.onboardingState = .init()
            state.currentViewState = .onboarding
        }
        
        private func handleOnboardingAction(state: inout AppState, action: OnboardingState.Action) {
            onboardingReducer.reduce(state: &state.onboardingState, action: action)
        }
        
        private func handleKidOperation(state: inout AppState,
                                        operation: CRUDOperation,
                                        kid: Kid,
                                        context: ModelContext) {
            switch operation {
            case .create:
                createKid(state: &state, kid: kid, context: context)
            case .update(let id):
                updateKid(state: &state, kid: kid, id: id, context: context)
            case .delete:
                fatalError("Delete kid is not supported")
            }
        }
        
        private func handleSleepSessionOperation(state: inout AppState,
                                                 operation: CRUDOperation,
                                                 sleepSession: SleepSession?,
                                                 context: ModelContext) {
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
            databaseService.replaceSleepSession(sessionId: updatedSession.id,
                                                with: updatedSession,
                                                for: selectedKid,
                                                context: context)
            
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
        
        private func updateSleepSession(state: inout AppState,
                                        sleepSession: SleepSession,
                                        id: String,
                                        context: ModelContext) {
            guard let currentKid = state.selectedKid else {
                print("No selected kid for updating a sleep session.")
                return
            }
            databaseService.replaceSleepSession(sessionId: id,
                                                with: sleepSession,
                                                for: currentKid,
                                                context: context)
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
            
            // Calculate the day before and after
            let calendar = Calendar.current
            guard let dayBeforeBefore = calendar.date(byAdding: .day, value: -2, to: selectedDate),
                  let dayBefore = calendar.date(byAdding: .day, value: -1, to: selectedDate),
                  let dayAfter = calendar.date(byAdding: .day, value: 1, to: selectedDate),
                  let dayAfterAfter = calendar.date(byAdding: .day, value: 2, to: selectedDate) else {
                print("Failed to calculate adjacent dates.")
                return
            }
            
            let datesToGenerate = [dayBeforeBefore, dayBefore, selectedDate, dayAfter, dayAfterAfter]
            
            var allNewSleepSessions: [SleepSessionViewRepresentation] = []
            
            for date in datesToGenerate {
                let wakeUpTime = state.sleepSessions.nightSleepEnding(on: date)?.endDate
                guard let newSchedule = sleepManager.getSleepSchedule(for: ageInMonths,
                                                                      wakeUpTime: wakeUpTime,
                                                                      baseDate: date) else {
                    print("Failed to generate sleep schedule for date: \(date)")
                    continue
                }
                let newSleepSessions = newSchedule.toViewRepresentations()
                allNewSleepSessions.append(contentsOf: newSleepSessions)
            }
            
            let savedSleepSessions = state.sleepSessions.filter { !$0.isScheduled }
            
            func sessionsOverlap(_ s1: SleepSessionViewRepresentation,
                                 _ s2: SleepSessionViewRepresentation) -> Bool {
                guard let s1End = s1.endDate, let s2End = s2.endDate else { return false }
                return s1.startDate < s2End && s2.startDate < s1End
            }
            
            let filteredNewSleepSessions = allNewSleepSessions.filter { newSession in
                !savedSleepSessions.contains { savedSession in
                    sessionsOverlap(newSession, savedSession)
                }
            }
            
            var mergedSleepSessions = state.sleepSessions
            
            // Remove existing scheduled sessions in the generated date range
            mergedSleepSessions.removeAll { session in
                session.isScheduled && datesToGenerate.contains {
                    calendar.isDate(session.startDate, inSameDayAs: $0)
                }
            }
            
            mergedSleepSessions.append(contentsOf: filteredNewSleepSessions)
            mergedSleepSessions.sort { $0.startDate < $1.startDate }
            
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
        
        private func debugPrint(item: CustomStringConvertible) {
            guard isDebugMode else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timestamp = formatter.string(from: Date())
            print("[\(timestamp)] Output: \(item)")
        }
    }
}

// MARK: - Store
extension AppState {
    // TODO: Think about how to make store an actor
    final class Store: ObservableObject {
        @Published private(set) var state: AppState
        private let reducer: Reducer
        
        init(state: AppState = .init(),
             databaseService: DatabaseService,
             settingsManager: SettingsManager = .init()) {
            self.state = state
            self.reducer = .init(onboardingReducer: .init(),
                                 databaseService: databaseService,
                                 settingsManager: settingsManager)
        }
        
        /// **Refactored**:
        /// 1. If the action is `.refresh(newState)`, update `self.state` on the main thread.
        /// 2. Otherwise, run the reducer off the main thread and then
        ///    dispatch `.refresh(newState)` to apply it.
        func dispatch(_ action: Action) {
            let newState = self.reducer.reduce(self.state, action: action)
            self.state = newState
        }
    }
}

// MARK: - SwiftUI Bindings

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
        )
    }
    
    var kidAgeBinding: Binding<Date?> {
        .init(
            get: { self.state.onboardingState.kidDateOfBirth },
            set: { [weak self] date in self?.dispatch(.onboarding(.setKidDateOfBirth(date))) }
        )
    }
    
    var sleepTimeBinding: Binding<Date?> {
        .init(
            get: { self.state.onboardingState.sleepTime ?? .now.evening() },
            set: { [weak self] date in self?.dispatch(.onboarding(.setSleepTime(date))) }
        )
    }
    
    var wakeTimeBinding: Binding<Date?> {
        .init(
            get: { self.state.onboardingState.wakeTime ?? .now.morning() },
            set: { [weak self] date in self?.dispatch(.onboarding(.setWakeTime(date))) }
        )
    }
    
    var sleepSessionInProgressBinding: Binding<SleepSessionViewRepresentation?> {
        .init(
            get: { self.state.sleepSessionInProgress },
            set: { _ in /* Intentionally left blank */ }
        )
    }
}
