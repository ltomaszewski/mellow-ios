//
//  ROnboardingView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 01/12/2024.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appStateStore: AppState.Store
    @Binding var onboardingCompleted: Bool

    var body: some View {
        VStack {
            ProgressBar(value: appStateStore.state.onboardingState.progress)
                .frame(height: 5)
                .padding(.top, 36)
                .padding(.horizontal, 16)
            
            // Onboarding Steps
            if !appStateStore.state.onboardingState.welcomeMessageShown {
                welcomeView
                    .transition(.push(from: .trailing))
            } else if appStateStore.state.onboardingState.childName.isEmpty {
                childNameInputView
                    .transition(.push(from: .trailing))
            } else if appStateStore.state.onboardingState.kidDateOfBirth == nil {
                kidAgeView
                    .transition(.push(from: .trailing))
            } else if appStateStore.state.onboardingState.sleepTime == nil {
                sleepTimeView
                    .transition(.push(from: .trailing))
            } else if appStateStore.state.onboardingState.wakeTime == nil {
                wakeTimeView
                    .transition(.push(from: .trailing))
            }
        }
        .background(Color.gunmetalBlue) // Ensure Color.gunmetalBlue is defined in your assets or extensions
        .onChange(of: appStateStore.state.onboardingState.completed) { _, completed in
            if completed {
                // Safely unwrap all required fields
                guard let dateOfBirth = appStateStore.state.onboardingState.kidDateOfBirth,
                      let sleepTime = appStateStore.state.onboardingState.sleepTime,
                      let wakeTime = appStateStore.state.onboardingState.wakeTime else {
                    // Handle the case where data might be missing
                    print("Onboarding completed but some fields are missing.")
                    return
                }
                
                let name = appStateStore.state.onboardingState.childName
                appStateStore.dispatch(.kidOperation(.create, Kid(name: name, dateOfBirth: dateOfBirth, sleepTime: sleepTime, wakeTime: wakeTime), modelContext))
                
                withAnimation {
                    onboardingCompleted = true
                }
            }
        }
    }
    
    // MARK: - Onboarding Step Views
    
    var welcomeView: some View {
        PlanPromptView(
            screenTapped: appStateStore.welcomeMessageShownBinding,
            headlineTopText: "",
            headlineText: "Answer a few questions\nto start personalizing your\nexperience.",
            headlineBottomText: "",
            headlineBottomTextImageName: "",
            bottomText: "Tap anywhere to continue"
        )
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(Color.gunmetalBlue)
    }
    
    var childNameInputView: some View {
        PlanTextInputView(
            value: appStateStore.childNameBinding,
            headlineText: "What's your child's name?",
            placeholderText: "Enter name here",
            submitText: "Continue"
        )
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(Color.gunmetalBlue)
    }
    
    var kidAgeView: some View {
        PlanDateInputView(
            value: appStateStore.kidAgeBinding,
            headlineText: "When was \(appStateStore.state.onboardingState.childName) born?",
            submitText: "Continue",
            datePickerType: .date // Assuming you modified PlanDateInputView to accept this parameter
        )
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(Color.gunmetalBlue)
    }
    
    var sleepTimeView: some View {
        PlanDateInputView(
            value: appStateStore.sleepTimeBinding,
            headlineText: "When does \(appStateStore.state.onboardingState.childName) usually fall asleep?",
            submitText: "Continue",
            datePickerType: .time
        )
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(Color.gunmetalBlue)
    }
    
    var wakeTimeView: some View {
        PlanDateInputView(
            value: appStateStore.wakeTimeBinding,
            headlineText: "When does \(appStateStore.state.onboardingState.childName) usually wake up?",
            submitText: "Continue",
            datePickerType: .time
        )
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(Color.gunmetalBlue)
    }
}

#Preview {
    @Previewable @State var appStateStore: AppState.Store = .init(state: .init(onboardingState: .init()),
                                                                  databaseService: DatabaseService())
    
    OnboardingView(onboardingCompleted: .init(get: { false }, set: { _ in }))
        .environmentObject(appStateStore)
        .modelContainer(.inMemoryContainer(for: Kid.self))
}

