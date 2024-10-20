//
//  ContentView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            if appState.showIntroView {
                IntroView(imageResource: .kidoHim,
                          text: "Science based sleep program that adapts to your kid.") {
                    withAnimation {
                        appState.completeIntro()
                    }
                }
            } else if !appState.isOnboardingCompleted {
                OnboardingView(onboardingCompleted: $appState.isOnboardingCompleted)
                    .animation(.bouncy, value: appState.showIntroView)
            } else {
                RootView().transition(.push(from: .bottom))
            }
        }
        .background(.gunmetalBlue)
        .onAppear(perform: {
            appState.databaseService.loadKids(context: modelContext)
        })
    }
}
