//
//  ROnboardingState.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 01/12/2024.
//

import Foundation
import SwiftlyBeautiful

// Current state of onboarding
struct OnboardingState: Codable {
    var welcomeMessageShown: Bool
    var childName: String
    var kidDateOfBirth: Date?
    var numberOfNaps: Int
    var sleepTime: Date?
    var wakeTime: Date?
    
    var completed: Bool
    
    var progress: Float {
        var completedSteps = 1
        let totalSteps = 7 // Updated to include the two new steps and nap update
        
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
        if numberOfNaps > 0 {
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
        numberOfNaps: Int = 0,
        sleepTime: Date? = nil,
        wakeTime: Date? = nil,
        completed: Bool = false
    ) {
        self.welcomeMessageShown = welcomeMessageShown
        self.childName = childName
        self.kidDateOfBirth = kidDateOfBirth
        self.numberOfNaps = numberOfNaps
        self.sleepTime = sleepTime
        self.wakeTime = wakeTime
        self.completed = completed
    }
}

// All possible actions for onboarding
extension OnboardingState {
    enum Action {
        case welcomeMessageShown
        case setChildName(String)
        case setKidDateOfBirth(Date?)
        case setSleepTime(Date?)
        case setWakeTime(Date?)
        case close
    }
}

extension OnboardingState {
    var isOnboardingCompleted: Bool {
        return welcomeMessageShown &&
        !childName.isEmpty &&
        kidDateOfBirth != nil &&
        sleepTime != nil &&
        wakeTime != nil
    }
}

// Action execution
extension OnboardingState {
    struct Reducer: ReducerProtocol {
        private let sleepManager = SleepManager()
        
        func reduce(state: inout OnboardingState, action: OnboardingState.Action) {
            switch action {
            case .welcomeMessageShown:
                state.welcomeMessageShown = true
                
            case .setChildName(let name):
                state.childName = name
                
            case .setKidDateOfBirth(let date):
                state.kidDateOfBirth = date
                guard let birthDate = date else { return }
                let ageInMonths = calculateAgeInMonths(birthDate: birthDate, from: Date())
                let napDurations = sleepManager.getNapDurations(for: ageInMonths)
                state.numberOfNaps = napDurations.count
                // Handle new actions
            case .setSleepTime(let date):
                state.sleepTime = date
                
            case .setWakeTime(let date):
                state.wakeTime = date
            case .close: break
            }
            
            // After handling any action, check if onboarding is completed
            state.completed = state.isOnboardingCompleted
        }
        
        /// Helper method to calculate age in months
        private func calculateAgeInMonths(birthDate: Date, from currentDate: Date) -> Int {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: birthDate, to: currentDate)
            let years = components.year ?? 0
            let months = components.month ?? 0
            return years * 12 + months
        }
    }
}

// TODO: Export Support for save to userdefaults to swiftMacro
// Extension for UserDefaults functionality with Enhanced Debug Mode
extension OnboardingState {
    
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
            UserDefaults.standard.set(encodedData, forKey: OnboardingState.userDefaultsKey)
            Self.log("ROnboardingState successfully saved to UserDefaults.")
        } catch {
            Self.log("Failed to encode ROnboardingState: \(error)")
        }
    }
    
    // MARK: - Load from UserDefaults
    /// Loads the ROnboardingState from UserDefaults if it exists.
    /// - Returns: An optional ROnboardingState instance.
    static func loadFromUserDefaults() -> OnboardingState? {
        let defaults = UserDefaults.standard
        guard let savedData = defaults.data(forKey: userDefaultsKey) else {
            log("No ROnboardingState found in UserDefaults.")
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let onboardingState = try decoder.decode(OnboardingState.self, from: savedData)
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

