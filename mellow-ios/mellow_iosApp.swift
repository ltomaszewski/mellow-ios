//
//  mellow_iosApp.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAnalytics

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
        return true
    }
}

@main
struct mellow_iosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var rAppStateStore = AppState.Store(databaseService: .init())
    
    // 1) Keep a ModelContainer property
    let container: ModelContainer
    
    // 2) Build the container in init(), specifying cloudKitDatabase: .none
    init() {
        do {
            // Turn off CloudKit sync:
            let config = ModelConfiguration(cloudKitDatabase: .none)
            container = try ModelContainer(
                for: Kid.self, SleepSession.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(rAppStateStore)
                // 3) Pass the container into the .modelContainer(...) modifier
                .modelContainer(container)
        }
    }
}
