//
//  AppState.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import Foundation
import Combine

class AppState: ObservableObject {
    @Published var isOnboardingCompleted: Bool = false
    @Published var showIntroView: Bool = true
    
    var databaseService = DatabaseService()
    var onboardingStore = OnboardingPlanStore()
    private var cancellables: [AnyCancellable] = []
    
    init() {
        // On app launch, check if onboarding is completed
        isOnboardingCompleted = onboardingStore.isOnboardingCompleted()
        showIntroView = !isOnboardingCompleted
        
        // Forward changes from databaseService to AppState's objectWillChange
        databaseService.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        // Optionally, if you want to observe onboardingStore as well
        onboardingStore.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func startIntro() {
        showIntroView = true
    }
    
    func completeIntro() {
        showIntroView = false
    }
}
