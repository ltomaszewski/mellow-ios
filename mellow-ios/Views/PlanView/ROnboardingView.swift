//
//  ROnboardingView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 01/12/2024.
//

import SwiftUI

struct ROnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var onboardingStore: ROnboardingState.Store
    @Binding var onboardingCompleted: Bool

    var body: some View {
        VStack {
            ProgressBar(value: onboardingStore.state.progress)
                .frame(height: 5)
                .padding(.top, 36)
                .padding(.horizontal, 16)
            
            // Onboarding Steps
            if !onboardingStore.state.welcomeMessageShown {
                welcomeView
                    .transition(.push(from: .trailing))
            } else if onboardingStore.state.childName.isEmpty {
                childNameInputView
                    .transition(.push(from: .trailing))
            } else if onboardingStore.state.kidDateOfBirth == nil {
                kidAgeView
                    .transition(.push(from: .trailing))
            } else if onboardingStore.state.sleepTime == nil {
                sleepTimeView
                    .transition(.push(from: .trailing))
            } else if onboardingStore.state.wakeTime == nil {
                wakeTimeView
                    .transition(.push(from: .trailing))
            }
        }
        .background(Color.gunmetalBlue) // Ensure Color.gunmetalBlue is defined in your assets or extensions
        .onChange(of: onboardingStore.state.completed) { completed in
            if completed {
                // Safely unwrap all required fields
                guard let dateOfBirth = onboardingStore.state.kidDateOfBirth,
                      let sleepTime = onboardingStore.state.sleepTime,
                      let wakeTime = onboardingStore.state.wakeTime else {
                    // Handle the case where data might be missing
                    print("Onboarding completed but some fields are missing.")
                    return
                }
                
                try? appState.databaseService.addKid(
                    name: onboardingStore.state.childName,
                    dateOfBirth: dateOfBirth,
                    sleepTime: sleepTime,
                    wakeTime: wakeTime,
                    context: modelContext
                )
                withAnimation {
                    onboardingCompleted = true
                }
            }
        }
    }
    
    // MARK: - Onboarding Step Views
    
    var welcomeView: some View {
        PlanPromptView(
            screenTapped: onboardingStore.welcomeMessageShownBinding,
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
            value: onboardingStore.childNameBinding,
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
            value: onboardingStore.kidAgeBinding,
            headlineText: "When was \(onboardingStore.state.childName) born?",
            submitText: "Continue",
            datePickerType: .date // Assuming you modified PlanDateInputView to accept this parameter
        )
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(Color.gunmetalBlue)
    }
    
    var sleepTimeView: some View {
        PlanDateInputView(
            value: onboardingStore.sleepTimeBinding,
            headlineText: "When does \(onboardingStore.state.childName) usually fall asleep?",
            submitText: "Continue",
            datePickerType: .time
        )
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(Color.gunmetalBlue)
    }
    
    var wakeTimeView: some View {
        PlanDateInputView(
            value: onboardingStore.wakeTimeBinding,
            headlineText: "When does \(onboardingStore.state.childName) usually wake up?",
            submitText: "Continue",
            datePickerType: .time
        )
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(Color.gunmetalBlue)
    }
}

//#Preview {
//    @Previewable @State var onboardingStore: ROnboardingState.Store = .init(state: .init())
//    
//    ROnboardingView(onboardingCompleted: .init(get: { false }, set: { _ in }))
//        .environmentObject(onboardingStore)
//}
