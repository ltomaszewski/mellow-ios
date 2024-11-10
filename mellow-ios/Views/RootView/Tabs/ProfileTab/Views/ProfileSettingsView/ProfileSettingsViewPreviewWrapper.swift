//
//  ProfileSettingsViewPreviewWrapper.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 10/11/2024.
//

import SwiftUI
import SwiftData

@MainActor
struct ProfileSettingsViewPreviewWrapper: View {
    init() {
        setupSampleData()
    }

    var body: some View {
        ProfileSettingsView()
            .modelContainer(sampleContainer)
    }

    // Create an in-memory ModelContainer with sample data
    private let sampleContainer: ModelContainer = {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        guard let container = try? ModelContainer(for: Kid.self, configurations: configuration) else {
            fatalError("Failed to create ModelContainer")
        }
        return container
    }()

    // Function to insert sample kids into the main context
    private func setupSampleData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"

        // Create sample Kid instances
        let kid1 = Kid(name: "Alice", dateOfBirth: formatter.date(from: "2015/06/15")!)
        let kid2 = Kid(name: "Bob", dateOfBirth: formatter.date(from: "2013/09/23")!)
        let kid3 = Kid(name: "Charlie", dateOfBirth: formatter.date(from: "2017/12/05")!)

        // Insert sample kids into the main context
        sampleContainer.mainContext.insert(kid1)
        sampleContainer.mainContext.insert(kid2)
        sampleContainer.mainContext.insert(kid3)
    }
}
