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
        NavigationView {
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
        .toolbar(.hidden)
        .foregroundColor(.white)
        .font(.main18)
    }
}

#Preview {
    ProfileTabView()
}
