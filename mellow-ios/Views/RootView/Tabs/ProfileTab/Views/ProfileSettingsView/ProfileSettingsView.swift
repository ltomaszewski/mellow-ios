//
//  ProfileSettingsView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 03/09/2024.
//

import SwiftUI
import SwiftData

struct ProfileSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var appStateStore: AppState.Store
    @Query(sort: \Kid.dateOfBirth) var kids: [Kid]
    
    @State private var isPushNotificationEnabled = false
    
    var body: some View {
        NavigationStack {
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
            .navigationBarHidden(true) // Hide the default navigation bar
        }
        .toolbar(.hidden)
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
            presentationMode.wrappedValue.dismiss()
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
            NavigationLink(destination: ProfileSettingsKidEditView(kid: kid)) {
                KidRowView(kid: kid)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Add Child Button View
    private var addChildButtonView: some View {
        Button(action: {
            withAnimation {
                appStateStore.dispatch(.openAddKidOnboarding)
            }
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

#Preview {
    ProfileSettingsViewPreviewWrapper()
}
