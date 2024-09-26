//
//  ProfileHeaderView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 03/09/2024.
//

import SwiftUI

struct ProfileHeaderView: View {
    @Binding var name: String
    @Binding var imageResource: ImageResource
    
    var body: some View {
        VStack(spacing: 8) {
            // Profile Picture Placeholder
            Image(imageResource)
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
            
            // Name
            Text(name)
                .font(.main18)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    ProfileHeaderView(name: .init(get: { "Lucas" }, set: { _ in } ),
                      imageResource: .init(get: { .profileAvatar }, set: { _ in }))
}
