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
        case sleepSessionOperation(CRUDOperation, Kid, ModelContext)
        case error(Error)
        case resetError
    }
    
    enum CRUDOperation {
        case create
        case update
        case delete
    }
}

// Action execution
extension RAppState {
    struct Reducer: ReducerProtocol {
        private let onboardingReducer: ROnboardingState.Reducer
        private weak var databaseService: DatabaseService?
        
        init(onboardingReducer: ROnboardingState.Reducer, databaseService: DatabaseService) {
            self.onboardingReducer = onboardingReducer
            self.databaseService = databaseService
        }
        
        func reduce(state: inout RAppState, action: RAppState.Action) {
            switch action {
            case .load(let context):
                let kids = databaseService?.loadKids(context: context) ?? []
                state.currentViewState = kids.isEmpty ? .intro : .root
            case .openAddKidOnboarding:
                ROnboardingState.removeFromUserDefaults()
                state.onboardingState = .init()
                state.currentViewState = .onboarding
            case .onboarding(let action):
                onboardingReducer.reduce(state: &state.onboardingState, action: action)
            case .kidOperation(let operation, let kid, let context):
                switch operation {
                case .create:
                    let kid = try? databaseService?.addKid(name: kid.name, dateOfBirth: kid.dateOfBirth, sleepTime: kid.sleepTime, wakeTime: kid.wakeTime, context: context)
                    guard let kid else { fatalError("Error save kid in the database") }
                    state.selectedKid = kid
                    state.currentViewState = .root
                case .update:
                    fatalError("Update kid is not supported")
                case .delete:
                    fatalError("Delete kid is not supported")
                }
            default:
                fatalError("Unsupported")
            }
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
