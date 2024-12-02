//
//  ROnboardingState.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 01/12/2024.
//

import Foundation
import SwiftlyBeautiful

// Current state of onboarding
struct ROnboardingState: Codable {
    var welcomeMessageShown: Bool
    var childName: String
    var kidDateOfBirth: Date?
    
    // New properties for sleep and wake times
    var sleepTime: Date?
    var wakeTime: Date?
    
    var completed: Bool
    
    var progress: Float {
        var completedSteps = 1
        let totalSteps = 6 // Updated to include the two new steps
        
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
        if sleepTime != nil {
            completedSteps += 1
        }
        if wakeTime != nil {
            completedSteps += 1
        }
        
        // Calculate and return the progress percentage.
        return Float(completedSteps) / Float(totalSteps)
    }
    
    // Initializer
    init(
        welcomeMessageShown: Bool = false,
        childName: String = "",
        kidDateOfBirth: Date? = nil,
        sleepTime: Date? = nil,
        wakeTime: Date? = nil,
        completed: Bool = false
    ) {
        self.welcomeMessageShown = welcomeMessageShown
        self.childName = childName
        self.kidDateOfBirth = kidDateOfBirth
        self.sleepTime = sleepTime
        self.wakeTime = wakeTime
        self.completed = completed
    }
}

// All possible actions for onboarding
extension ROnboardingState {
    enum Action {
        case welcomeMessageShown
        case setChildName(String)
        case setKidDateOfBirth(Date?)
        
        // New actions for sleep and wake times
        case setSleepTime(Date?)
        case setWakeTime(Date?)
    }
}

extension ROnboardingState {
    var isOnboardingCompleted: Bool {
        return welcomeMessageShown &&
               !childName.isEmpty &&
               kidDateOfBirth != nil &&
               sleepTime != nil &&
               wakeTime != nil
    }
}

// Action execution
extension ROnboardingState {
    struct Reducer: ReducerProtocol {
        func reduce(state: inout ROnboardingState, action: ROnboardingState.Action) {
            switch action {
            case .welcomeMessageShown:
                state.welcomeMessageShown = true
                
            case .setChildName(let name):
                state.childName = name
                
            case .setKidDateOfBirth(let date):
                state.kidDateOfBirth = date
                
            // Handle new actions
            case .setSleepTime(let date):
                state.sleepTime = date
                
            case .setWakeTime(let date):
                state.wakeTime = date
            }
            
            // After handling any action, check if onboarding is completed
            state.completed = state.isOnboardingCompleted
        }
    }
}


// TODO: Export Support for save to userdefaults to swiftMacro
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
        encoder.dateEncodingStrategy = .iso8601
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
        decoder.dateDecodingStrategy = .iso8601
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

