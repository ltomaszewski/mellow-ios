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
    @State private var onboardingCompleted: Bool = false
    
    var body: some View {
        VStack {
            if showIntroView {
                IntroView(imageResource: .kidoHim,
                          text: "Science based sleep program that adapts to your kid.") {
                    withAnimation {
                        showIntroView = false
                    }
                }
            } else if !onboardingCompleted {
                ROnboardingView(onboardingCompleted: $onboardingCompleted)
            } else {
                RootView().transition(.push(from: .bottom))
            }
        }
        .background(.gunmetalBlue)
        .onReceive(appState.$addNewKids.filter { $0 }, perform: { newValue in
            onboardingStore.removeStateFormUserDefaults()
            withAnimation {
                showIntroView = true
                onboardingCompleted = false
            }
        })
        .onAppear(perform: {
            //TODO: Reset does not work
//            appState.reset(context: modelContext)
            let kids = appState.databaseService.loadKids(context: modelContext)
            let hasKidInDatabase = !kids.isEmpty
            showIntroView = !hasKidInDatabase
            onboardingCompleted = hasKidInDatabase
        })
    }
}
