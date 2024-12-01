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
            if !onboardingStore.state.welcomeMessageShown {
                welcomeView
                    .transition(.push(from: .trailing))
            } else if onboardingStore.state.childName.isEmpty {
                childNameInputView
                    .transition(.push(from: .trailing))
            } else if onboardingStore.state.kidDateOfBirth == nil{
                kidAgeView
                    .transition(.push(from: .trailing))
            }
        }
        .background(.gunmetalBlue)
        .onChange(of: onboardingStore.state.completed, {
            appState.databaseService.addKid(name: onboardingStore.state.childName,
                                            dateOfBirth: onboardingStore.state.kidDateOfBirth!,
                                            context: modelContext)
            withAnimation {
                onboardingCompleted = true
            }
        })
    }
    
    var welcomeView: some View {
        PlanPromptView(screenTapped: onboardingStore.welcomeMessageShownBinding,
                       headlineTopText: "",
                       headlineText: "Answer a few questions\nto start personalizing your\nexperience.",
                       headlineBottomText: "",
                       headlineBottomTextImageName: "",
                       bottomText: "Tap anywhere to continue")
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(.gunmetalBlue)
    }
    
    var childNameInputView: some View {
        PlanTextInputView(value: onboardingStore.childNameBinding,
                          headlineText: "What's your child's name?",
                          placeholderText: "Enter name here",
                          submitText: "Continue")
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(.gunmetalBlue)
    }
    
    var kidAgeView: some View {
        PlanDateInputView(value: onboardingStore.kidAgeBinding,
                          headlineText: "When \(onboardingStore.state.childName) was born?",
                          submitText: "Continue")
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(.gunmetalBlue)
    }
}

//#Preview {
//    @Previewable @State var onboardingStore: ROnboardingState.Store = .init(state: .init())
//    
//    ROnboardingView(onboardingCompleted: .init(get: { false }, set: { _ in }))
//        .environmentObject(onboardingStore)
//}
