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
            } else if appState.onboardingStore.kidAge.isEmpty {
                questionView
                    .transition(.push(from: .trailing))
            } else if appState.onboardingStore.childName.isEmpty {
                textInputView
                    .transition(.push(from: .trailing))
            }
        }
        .background(.gunmetalBlue)
        .onChange(of: appState.onboardingStore.welcomeMessageShown) { appState.onboardingStore.markOnboardingComplete() }
        .onChange(of: appState.onboardingStore.kidAge) { appState.onboardingStore.markOnboardingComplete() }
        .onChange(of: appState.onboardingStore.childName) { appState.onboardingStore.markOnboardingComplete() }
        .onChange(of: appState.onboardingStore.completed, {
            appState.databaseService.addKid(name: appState.onboardingStore.childName,
                                            age: appState.onboardingStore.kidAge,
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
    
    var questionView: some View {
        PlanQuestionView(selectedOption: $appState.onboardingStore.kidAge,
                         question: "What best describe your kid’s age?",
                         options: [
                            "Newborn (0-3mo)",
                            "Baby (3-12mo)",
                            "Toddler (1-3 year)",
                            "Preschool (3-5 year)",
                            "School (5-11 year)",
                            "Teen (11+ year)"
                         ],
                         dontKnow: "Don't know")
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
}

#Preview {
    OnboardingView(onboardingCompleted: .init(get: { false }, set: { _ in }))
}
