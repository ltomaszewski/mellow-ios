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
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var databaseStore: DatabaseStore
    
    var body: some View {
        VStack {
            ProgressBar(value: store.progress)
                .frame(height: 5)
                .padding(.top, 36)
                .padding(.horizontal, 16)
            if !store.welcomeMessageShown {
                welcomeView
                    .transition(.push(from: .trailing))
            } else if store.kidAge.isEmpty {
                questionView
                    .transition(.push(from: .trailing))
            } else if store.childName.isEmpty {
                textInputView
                    .transition(.push(from: .trailing))
            }
        }
        .background(.gunmetalBlue)
        .onChange(of: store.welcomeMessageShown) { store.markOnboardingComplete() }
        .onChange(of: store.kidAge) { store.markOnboardingComplete() }
        .onChange(of: store.childName) { store.markOnboardingComplete() }
        .onChange(of: store.completed, {
            databaseStore.addKid(name: store.childName,
                                 age: store.kidAge,
                                 context: modelContext)
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

#Preview {
    OnboardingView(onboardingCompleted: .init(get: { false }, set: { _ in }))
}
