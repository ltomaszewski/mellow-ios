//
//  ROnboardingState.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 01/12/2024.
//

import Foundation

// Current state of onboarding
struct ROnboardingState: Codable {
    var welcomeMessageShown: Bool
    var childName: String
    var kidDateOfBirth: Date?
    var completed: Bool
    var progress: Float {
        var completedSteps = 0
        let totalSteps = 3 // Updated to remove the `kidAge` step.
        
        // Increment `completedSteps` for each completed onboarding step.
        if welcomeMessageShown {
            completedSteps += 1
        }
        if !childName.isEmpty {
            completedSteps += 1
        }
        if kidDateOfBirth != nil {
            completedSteps += 1
        }
        
        // Calculate and return the progress percentage.
        return Float(completedSteps) / Float(totalSteps)
    }
    
    // TODO: We have copy on write here, so in case the copy is created an init will be executed with the same value? Or how the sturct is copied under the hood
    // Tested: Init on copy is not called at all. So the progress was not updated, thats why I had to export it to compund property as minimal deliver value
    init(welcomeMessageShown: Bool = false, childName: String = "", kidDateOfBirth: Date? = nil, completed: Bool = false) {
        self.welcomeMessageShown = welcomeMessageShown
        self.childName = childName
        self.kidDateOfBirth = kidDateOfBirth
        self.completed = completed
    }
}

// All possible actions for onboarding
extension ROnboardingState {
    enum Action {
        case welcomeMessageShown
        case setChildName(String)
        case setKidDateOfBirth(Date?)
    }
}

// Action execution
extension ROnboardingState {
    struct Reducer: ReducerProtocol {
        func reduce(state: inout ROnboardingState, action: ROnboardingState.Action) {
            switch action {
            case .welcomeMessageShown: state.welcomeMessageShown = true
            case .setChildName(let name): state.childName = name
            case .setKidDateOfBirth(let date):
                state.kidDateOfBirth = date
                // Validation if the onboarding is completed
                if state.welcomeMessageShown && !state.childName.isEmpty && state.kidDateOfBirth != nil {
                    state.completed = true
                }
            }
        }
    }
}

// ROnbardingState Store
extension ROnboardingState {
    class Store: ObservableObject {
        @Published private(set) var state: ROnboardingState
        private let reducer: Reducer = .init()
        
        init(state: ROnboardingState? = ROnboardingState.loadFromUserDefaults()) {
            self.state = state ?? .init()
        }
        
        func dispatch(_ action: ROnboardingState.Action) {
            reducer.reduce(state: &state, action: action)
            state.saveToUserDefaults()
        }
    }
}

import SwiftUI

// Binding for State and swfitUI TODO: Export to swift Macro
extension ROnboardingState.Store {
    var welcomeMessageShownBinding: Binding<Bool> {
        .init(get: { false }, set: { [weak self] _ in self?.dispatch(.welcomeMessageShown) })
    }
    
    var childNameBinding: Binding<String> {
        .init(get: { self.state.childName }, set: { [weak self] name in self?.dispatch(.setChildName(name)) }) // TODO: Research If weak self is really needed here
    }
    
    var kidAgeBinding: Binding<Date?> {
        .init(get: { self.state.kidDateOfBirth }, set: { [weak self] date in self?.dispatch(.setKidDateOfBirth(date)) })
    }
}

// Extension for UserDefaults functionality with Enhanced Debug Mode
extension ROnboardingState {
    
    // MARK: - UserDefaults Key
    private static let userDefaultsKey = "ROnboardingStateKey"
    
    // MARK: - Debug Mode Flag
    /// Static property to control debug logging.
    static var isDebugMode: Bool = false
    
    /// Enables debug mode for ROnboardingState extension.
    static func enableDebugMode() {
        isDebugMode = true
        print("ROnboardingState debug mode enabled.")
    }
    
    /// Disables debug mode for ROnboardingState extension.
    static func disableDebugMode() {
        isDebugMode = true
        print("ROnboardingState debug mode disabled.")
    }
    
    // MARK: - Dedicated Logging Method
    /// Logs a message to the console if debug mode is enabled.
    /// - Parameter message: The message to be logged.
    private static func log(_ message: String) {
        if isDebugMode {
            print("DEBUG: \(message)")
        }
    }
    
    // MARK: - Save to UserDefaults
    /// Saves the current ROnboardingState instance to UserDefaults.
    func saveToUserDefaults() {
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(self)
            UserDefaults.standard.set(encodedData, forKey: ROnboardingState.userDefaultsKey)
            Self.log("ROnboardingState successfully saved to UserDefaults.")
        } catch {
            Self.log("Failed to encode ROnboardingState: \(error)")
        }
    }
    
    // MARK: - Load from UserDefaults
    /// Loads the ROnboardingState from UserDefaults if it exists.
    /// - Returns: An optional ROnboardingState instance.
    static func loadFromUserDefaults() -> ROnboardingState? {
        let defaults = UserDefaults.standard
        guard let savedData = defaults.data(forKey: userDefaultsKey) else {
            log("No ROnboardingState found in UserDefaults.")
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            let onboardingState = try decoder.decode(ROnboardingState.self, from: savedData)
            log("ROnboardingState successfully loaded from UserDefaults.")
            return onboardingState
        } catch {
            log("Failed to decode ROnboardingState: \(error)")
            return nil
        }
    }
    
    // MARK: - Check Existence
    /// Checks whether an ROnboardingState exists in UserDefaults.
    /// - Returns: A Boolean indicating the presence of ROnboardingState in UserDefaults.
    static func existsInUserDefaults() -> Bool {
        let defaults = UserDefaults.standard
        let exists = defaults.data(forKey: userDefaultsKey) != nil
        log("ROnboardingState exists in UserDefaults: \(exists)")
        return exists
    }
    
    // MARK: - Remove from UserDefaults
    /// Removes the ROnboardingState from UserDefaults.
    static func removeFromUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: userDefaultsKey)
        log("ROnboardingState has been removed from UserDefaults.")
    }
}

