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

    var body: some View {
        VStack {
            switch appStateStore.state.currentViewState {
            case .intro:
                IntroView(imageResource: .kidoHim,
                          text: "Science based sleep program that adapts to your kid.") {
                    withAnimation {
                        appStateStore.dispatch(.openAddKidOnboarding)
                    }
                }
            case .onboarding:
                OnboardingView()
            case .root:
                RootView().transition(.push(from: .bottom))
            }
        }
        .background(.gunmetalBlue)
        .onAppear(perform: {
            appStateStore.dispatch(.load(modelContext))
            UIDatePicker.appearance().overrideUserInterfaceStyle = .light
        })
    }
}

#Preview("Default") {
    ContentView()
        .environmentObject(AppState.Store(databaseService: DatabaseService()))
        .modelContainer(for: [Kid.self, SleepSession.self], inMemory: true)
}
