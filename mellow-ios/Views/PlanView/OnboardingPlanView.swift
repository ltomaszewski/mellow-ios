//
//  OnboardingPlanView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    
    @Binding var onboardingCompleted: Bool
    
    var body: some View {
        VStack {
            ProgressBar(value: appState.onboardingStore.progress)
                .frame(height: 5)
                .padding(.top, 36)
                .padding(.horizontal, 16)
            if !appState.onboardingStore.welcomeMessageShown {
                welcomeView
                    .transition(.push(from: .trailing))
            } else if appState.onboardingStore.childName.isEmpty {
                textInputView
                    .transition(.push(from: .trailing))
            } else if appState.onboardingStore.kidDateOfBirth == nil {
                dateInputView
                    .transition(.push(from: .trailing))
            }
        }
        .background(.gunmetalBlue)
        .onChange(of: appState.onboardingStore.welcomeMessageShown) { appState.onboardingStore.markOnboardingComplete() }
        .onChange(of: appState.onboardingStore.childName) { appState.onboardingStore.markOnboardingComplete() }
        .onChange(of: appState.onboardingStore.kidDateOfBirth, { appState.onboardingStore.markOnboardingComplete() })
        .onChange(of: appState.onboardingStore.completed, {
            appState.databaseService.addKid(name: appState.onboardingStore.childName,
                                            dateOfBirth: appState.onboardingStore.kidDateOfBirth!,
                                            context: modelContext)
            withAnimation {
                onboardingCompleted = true
            }
        })
    }
    
    var welcomeView: some View {
        PlanPromptView(screenTapped: $appState.onboardingStore.welcomeMessageShown, // TODO: Research why onboardingStore has to be var to be able to provide value for this class
                       headlineTopText: "",
                       headlineText: "Answer a few questions\nto start personalizing your\nexperience.",
                       headlineBottomText: "",
                       headlineBottomTextImageName: "",
                       bottomText: "Tap anywhere to continue")
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(.gunmetalBlue)
    }
    
    var textInputView: some View {
        PlanTextInputView(value: $appState.onboardingStore.childName,
                          headlineText: "What's your child's name?",
                          placeholderText: "Enter name here",
                          submitText: "Continue")
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(.gunmetalBlue)
    }
    
    var dateInputView: some View {
        PlanDateInputView(value: $appState.onboardingStore.kidDateOfBirth,
                          headlineText: "When \(appState.onboardingStore.childName) was born?",
                          submitText: "Continue")
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(.gunmetalBlue)
    }
}

#Preview {
    OnboardingView(onboardingCompleted: .init(get: { false }, set: { _ in }))
}
