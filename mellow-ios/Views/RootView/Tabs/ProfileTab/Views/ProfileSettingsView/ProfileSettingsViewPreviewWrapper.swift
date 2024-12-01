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

        // Create a Calendar instance for setting specific times
        let calendar = Calendar.current

        // Helper function to create a Date with specific hour and minute
        func createTime(hour: Int, minute: Int) -> Date {
            // Use today's date for the time components
            let now = Date()
            guard let date = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) else {
                fatalError("Failed to create time with hour: \(hour), minute: \(minute)")
            }
            return date
        }

        // Define sleepTime and wakeTime for sample kids
        let sleepTimeAlice = createTime(hour: 20, minute: 30) // 8:30 PM
        let wakeTimeAlice = createTime(hour: 7, minute: 0)    // 7:00 AM

        let sleepTimeBob = createTime(hour: 21, minute: 0)    // 9:00 PM
        let wakeTimeBob = createTime(hour: 6, minute: 30)     // 6:30 AM

        let sleepTimeCharlie = createTime(hour: 19, minute: 45) // 7:45 PM
        let wakeTimeCharlie = createTime(hour: 8, minute: 15)    // 8:15 AM

        // Create sample Kid instances with all required fields
        let kid1 = Kid(
            name: "Alice",
            dateOfBirth: formatter.date(from: "2015/06/15")!,
            sleepTime: sleepTimeAlice,
            wakeTime: wakeTimeAlice
        )

        let kid2 = Kid(
            name: "Bob",
            dateOfBirth: formatter.date(from: "2013/09/23")!,
            sleepTime: sleepTimeBob,
            wakeTime: wakeTimeBob
        )

        let kid3 = Kid(
            name: "Charlie",
            dateOfBirth: formatter.date(from: "2017/12/05")!,
            sleepTime: sleepTimeCharlie,
            wakeTime: wakeTimeCharlie
        )

        // Insert sample kids into the main context
        sampleContainer.mainContext.insert(kid1)
        sampleContainer.mainContext.insert(kid2)
        sampleContainer.mainContext.insert(kid3)

        // Optionally, save the context if needed
        do {
            try sampleContainer.mainContext.save()
        } catch {
            fatalError("Failed to save sample data: \(error)")
        }
    }
}
