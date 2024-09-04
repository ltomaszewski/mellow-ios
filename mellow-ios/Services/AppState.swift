//
//  AppState.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import Foundation

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isOnboardingCompleted: Bool = false
    @Published var showIntroView: Bool = true
    
    private let onboardingStore = OnboardingPlanStore.shared
    
    init() {
        // On app launch, check if onboarding is completed
        isOnboardingCompleted = onboardingStore.isOnboardingCompleted()
        showIntroView = !isOnboardingCompleted
    }

    func startIntro() {
        showIntroView = true
    }
    
    func completeIntro() {
        showIntroView = false
    }
}
