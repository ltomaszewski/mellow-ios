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

// IMPORTANT: Import React's RCTAppDelegate to subclass it
import React
import React_RCTAppDelegate

/// Our custom AppDelegate that now inherits from React Native's RCTAppDelegate
class AppDelegate: RCTAppDelegate {
    
    /// Override `application(_:didFinishLaunchingWithOptions:)`
    /// to configure Firebase, analytics, and React Native.
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        // Tell RCTAppDelegate not to automatically create a new window & rootViewController
        // (we rely on SwiftUI’s lifecycle for the app window).
        self.automaticallyLoadReactNativeWindow = false
        
        // Configure Firebase
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /// React Native expects to know where the JS bundle URL is located.
    override func sourceURL(for bridge: RCTBridge) -> URL? {
        return self.bundleURL()
    }
    
    /// Provide the bundle URL either from Metro (DEBUG) or from a compiled JS bundle
    override func bundleURL() -> URL? {
#if DEBUG
        return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
#else
        return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
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
            ReactView(
                moduleName: "mellow-react-native",
                rootViewFactory: delegate.rootViewFactory
            )
            //            ContentView()
            //                .environmentObject(rAppStateStore)
            //                .modelContainer(container)
        }
    }
}
