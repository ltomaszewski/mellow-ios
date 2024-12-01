//
//  ContentView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appStateStore: RAppState.Store
    @Environment(\.modelContext) private var modelContext
    
    @State private var onboardingCompleted: Bool = false

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
                ROnboardingView(onboardingCompleted: $onboardingCompleted)
            case .root:
                RootView().transition(.push(from: .bottom))
            }
        }
        .background(.gunmetalBlue)
        .onAppear(perform: {
            //TODO: Reset does not work
            //            appState.reset(context: modelContext)
            appStateStore.dispatch(.load(modelContext))
        })
    }
}
