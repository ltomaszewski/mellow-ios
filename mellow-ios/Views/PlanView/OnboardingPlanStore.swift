//
//  OnboardingPlanStore.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import Foundation

class OnboardingPlanStore: ObservableObject {
    static let shared = OnboardingPlanStore() // Singleton instance
    private init() {
        loadData()
    }
    
    @Published var welcomeMessageShown: Bool = false
    @Published var kidAge: String = ""
    @Published var childName: String = ""
    @Published var completed: Bool = false
    
    private let userDefaults = UserDefaults.standard
    
    // UserDefaults keys
    private let onboardingCompleteKey = "OnboardingComplete"
    private let kidAgeKey = "KidAge"
    private let childNameKey = "ChildName"
    
    // Load data from UserDefaults
    private func loadData() {
        welcomeMessageShown = userDefaults.bool(forKey: onboardingCompleteKey)
        kidAge = userDefaults.string(forKey: kidAgeKey) ?? ""
        childName = userDefaults.string(forKey: childNameKey) ?? ""
    }
    
    // Save the onboarding completion status
    func markOnboardingComplete() {
        guard welcomeMessageShown, !kidAge.isEmpty, !childName.isEmpty else { return }
        userDefaults.set(true, forKey: onboardingCompleteKey)
        userDefaults.set(kidAge, forKey: kidAgeKey)
        userDefaults.set(childName, forKey: childNameKey)
        welcomeMessageShown = true
        completed = true
    }
    
    // Reset onboarding (for debugging or re-testing)
    func resetOnboarding() {
        userDefaults.removeObject(forKey: onboardingCompleteKey)
        userDefaults.removeObject(forKey: kidAgeKey)
        userDefaults.removeObject(forKey: childNameKey)
        welcomeMessageShown = false
        kidAge = ""
        childName = ""
    }
    
    // Check if onboarding is already completed
    func isOnboardingCompleted() -> Bool {
        return userDefaults.bool(forKey: onboardingCompleteKey)
    }
}
