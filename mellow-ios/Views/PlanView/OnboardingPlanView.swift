//
//  OnboardingPlanView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var onboardingCompleted: Bool
    @ObservedObject var store = OnboardingPlanStore.shared
    
    var body: some View {
        VStack {
            if !store.welcomeMessageShown {
                welcomeView.transition(.slide)
            } else if store.kidAge.isEmpty {
                questionView.transition(.opacity)
            } else if store.childName.isEmpty {
                textInputView.transition(.opacity)
            }
        }
        .onChange(of: store.welcomeMessageShown) { store.markOnboardingComplete() }
        .onChange(of: store.kidAge) { store.markOnboardingComplete() }
        .onChange(of: store.childName) { store.markOnboardingComplete() }
        .onChange(of: store.completed, {
            withAnimation {
                onboardingCompleted = true
            }
        })
    }
    
    var welcomeView: some View {
        PlanPromptView(screenTapped: $store.welcomeMessageShown,
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
        PlanQuestionView(selectedOption: $store.kidAge,
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
        PlanTextInputView(value: $store.childName,
                          headlineText: "What's your child's name?",
                          placeholderText: "Enter name here",
                          submitText: "Continue")
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(.gunmetalBlue)
    }
}
