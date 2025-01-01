//
//  ContentView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appStateStore: AppState.Store
    @Environment(\.modelContext) private var modelContext

    @State private var animatedViewState: AppState.CurrentViewState = .intro

    var body: some View {
        VStack {
            switch animatedViewState {
            case .intro:
                IntroView(imageResource: .kidoHim,
                          text: "Science-based sleep program that adapts to your kid.") {
                    withAnimation {
                        appStateStore.dispatch(.openAddKidOnboarding)
                    }
                }
            case .onboarding:
                OnboardingView()
                    .transition(.push(from: .bottom))
            case .signUp:
                SignUpView()
                    .transition(.push(from: .bottom))
            case .root:
                RootView()
                    .transition(.push(from: .bottom))
            }
        }
        .background(Color.deepNight)
        .onAppear {
            appStateStore.dispatch(.load(modelContext))
            UIDatePicker.appearance().overrideUserInterfaceStyle = .light
        }
        .onChange(of: appStateStore.state.currentViewState) { _, newViewState in
            withAnimation {
                animatedViewState = newViewState
            }
        }
    }
}

#Preview("Default") {
    ContentView()
        .environmentObject(AppState.Store(databaseService: DatabaseService()))
        .modelContainer(for: [Kid.self, SleepSession.self], inMemory: true)
}
