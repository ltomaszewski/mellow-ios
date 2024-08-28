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
    var databaseStore = DatabaseStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(databaseStore)
        }
    }
}
