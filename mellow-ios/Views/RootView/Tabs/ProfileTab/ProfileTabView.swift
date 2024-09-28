//
//  ProfileTabView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/08/2024.
//

import SwiftUI

struct ProfileTabView: View {
    @State private var navigateToSettings = false
    
    var body: some View {
        NavigationStack {
            ProfileView()
                .navigationTitle(Text("Profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.main18)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileSettingsView()) {
                        Image(.settings)
                    }
                }
            }
        }
        .foregroundColor(.white)
        .font(.main18)
    }
}

#Preview {
    ProfileTabView()
}
