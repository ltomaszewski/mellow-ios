//
//  OnboardingPlanStore.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import Foundation

/// `OnboardingPlanStore` is a singleton class responsible for managing the onboarding process.
/// It keeps track of the user's progress through the onboarding steps, stores relevant data,
/// and provides utilities to check completion status and calculate progress.
class OnboardingPlanStore: ObservableObject {
    /// Private initializer to ensure only one instance is created.
    init() {
        loadData()
    }
    
    // MARK: - Published Properties
    
    /// Indicates whether the welcome message has been shown.
    @Published var welcomeMessageShown: Bool = false
    
    /// Stores the name of the child.
    @Published var childName: String = ""
    
    /// Stores the date of birth of the child.
    @Published var kidDateOfBirth: Date? = nil
    
    /// Indicates whether the onboarding process is completed.
    @Published var completed: Bool = false
    
    // MARK: - UserDefaults Management
    
    /// Reference to the standard `UserDefaults`.
    private let userDefaults = UserDefaults.standard
    
    /// Keys used for storing data in `UserDefaults`.
    private let onboardingCompleteKey = "OnboardingComplete"
    private let childNameKey = "ChildName"
    private let kidDateOfBirthKey = "KidDateOfBirth"
    
    /// Loads data from `UserDefaults` to initialize the properties.
    private func loadData() {
        welcomeMessageShown = userDefaults.bool(forKey: onboardingCompleteKey)
        childName = userDefaults.string(forKey: childNameKey) ?? ""
        
        // Load the date of birth from UserDefaults, converting from TimeInterval if it exists.
        if let dateOfBirthInterval = userDefaults.object(forKey: kidDateOfBirthKey) as? TimeInterval {
            kidDateOfBirth = Date(timeIntervalSince1970: dateOfBirthInterval)
        } else {
            kidDateOfBirth = nil
        }
    }
    
    // MARK: - Onboarding Control Methods
    
    /// Marks the onboarding process as complete if all required information is provided.
    func markOnboardingComplete() {
        // Ensure all required fields are filled before marking as complete.
        guard welcomeMessageShown,
              !childName.isEmpty,
              kidDateOfBirth != nil else { return }
        
        // Save the data to `UserDefaults`.
        userDefaults.set(true, forKey: onboardingCompleteKey)
        userDefaults.set(childName, forKey: childNameKey)
        userDefaults.set(kidDateOfBirth, forKey: kidDateOfBirthKey)
        
        // Update the completion status.
        welcomeMessageShown = true
        completed = true
    }
    
    /// Resets the onboarding process by clearing stored data.
    func resetOnboarding() {
        // Remove stored data from `UserDefaults`.
        userDefaults.removeObject(forKey: onboardingCompleteKey)
        userDefaults.removeObject(forKey: childNameKey)
        userDefaults.removeObject(forKey: kidDateOfBirthKey)
        
        // Reset the properties to their default values.
        welcomeMessageShown = false
        childName = ""
        kidDateOfBirth = nil
    }
    
    /// Checks if the onboarding process has been completed.
    /// - Returns: A `Bool` indicating the completion status.
    func isOnboardingCompleted() -> Bool {
        return userDefaults.bool(forKey: onboardingCompleteKey)
    }
    
    // MARK: - Progress Tracking
    
    /// Calculates the progress of the onboarding process.
    /// - Returns: A `Float` value between 0.0 and 1.0 representing the completion percentage.
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
}
