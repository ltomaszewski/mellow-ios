//
//  ProfileSettingsView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 03/09/2024.
//

import SwiftUI
import SwiftData

struct ProfileSettingsView: View {
    @Query(sort: \Kid.dateOfBirth) var kids: [Kid]
    
    @State private var isPushNotificationEnabled = false
    
    var body: some View {
        VStack(spacing: 1) {
            headerView
            kidsListView
            addChildButtonView
            pushNotificationsView
            logoutButtonView
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.deepNight)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            closeButton
            Spacer()
            Text("Settings")
                .font(.main18)
                .foregroundColor(.white)
            Spacer()
            // Optionally, you can add another button or leave it empty
            Spacer().frame(width: 14) // To balance the HStack
        }
        .padding(16)
    }
    
    private var closeButton: some View {
        Button(action: {
            print("Close")
        }) {
            Image(.close)
                .renderingMode(.template)
                .resizable()
                .foregroundColor(.white)
                .frame(width: 14, height: 14)
        }
    }
    
    // MARK: - Kids List View
    private var kidsListView: some View {
        ForEach(kids) { kid in
            KidRowView(kid: kid)
        }
    }
    
    // MARK: - Add Child Button View
    private var addChildButtonView: some View {
        Button(action: {
            print("Add child")
        }) {
            Text("Add child")
                .font(.main16)
                .foregroundColor(Color.primary300)
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color.gunmetalBlue)
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Push Notifications View
    private var pushNotificationsView: some View {
        HStack {
            Text("Push Notifications")
                .font(.main16)
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isPushNotificationEnabled)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(Color.gunmetalBlue)
        .padding(.bottom, 24)
    }
    
    // MARK: - Logout Button View
    private var logoutButtonView: some View {
        Button(action: {
            print("Log out")
        }) {
            Text("Log out")
                .font(.main16)
                .foregroundColor(Color.primary300)
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color.gunmetalBlue)
        }
    }
}

// MARK: - KidRowView
struct KidRowView: View {
    var kid: Kid
    
    var body: some View {
        HStack(spacing: 16) {
            Image(kid.isHim ? .kidoHim : .kidoHer) // Assuming different images based on `isHim`
                .resizable()
                .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(kid.name)
                    .font(.main20)
                    .foregroundColor(.white)
                
                Text(kid.ageFormatted)
                    .font(.main14)
                    .foregroundColor(.slateGray)
            }
            
            Spacer()
            
            Image(.arrowRight)
                .resizable()
                .frame(width: 8, height: 14)
        }
        .padding(16)
        .background(Color.gunmetalBlue)
    }
}

// MARK: - PreviewProvider with @MainActor
struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsViewPreviewWrapper()
            .previewLayout(.sizeThatFits)
    }
}

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
