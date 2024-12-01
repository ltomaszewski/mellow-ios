//
//  ContentView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 04/09/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var onboardingStore: ROnboardingState.Store
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    
    @State private var showIntroView: Bool = true
    
    var body: some View {
        VStack {
            if showIntroView {
                IntroView(imageResource: .kidoHim,
                          text: "Science based sleep program that adapts to your kid.") {
                    withAnimation {
                        showIntroView = false
                    }
                }
            } else if !onboardingStore.state.completed {
                ROnboardingView(onboardingCompleted: .init(get: { false }, set: { _ in }))
            } else {
                RootView().transition(.push(from: .bottom))
            }
        }
        .background(.gunmetalBlue)
        .onAppear(perform: {
//            appState.reset(context: modelContext)
            appState.databaseService.loadKids(context: modelContext)
        })
    }
}
