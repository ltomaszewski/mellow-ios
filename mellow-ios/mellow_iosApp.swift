//
//  mellow_iosApp.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI
import SwiftData

@main
struct mellow_iosApp: App {
    @StateObject var databaseStore = DatabaseStore()
    @StateObject var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(databaseStore)
        }
    }
}
