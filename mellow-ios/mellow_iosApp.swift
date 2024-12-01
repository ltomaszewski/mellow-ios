//
//  mellow_iosApp.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI
import SwiftData

/*
 1. Add support for more then one onboarding session
 2. Onboarding is on start only if the array of kids is empty
 3. Open onboarding process from profile
 4. Add wake up and bad time time in onboarding process
 */

@main
struct mellow_iosApp: App {
    @StateObject var appState = AppState()
    @StateObject var onboardingStore = ROnboardingState.Store()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(onboardingStore)
        }
        .modelContainer(for: [Kid.self, SleepSession.self])
    }
}
