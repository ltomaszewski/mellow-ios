//
//  ProfileHeaderView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 03/09/2024.
//

import SwiftUI

struct ProfileHeaderView: View {
    var name: String
    var imageResource: ImageResource
    
    var body: some View {
        VStack(spacing: 8) {
            // Profile Picture Placeholder
            Image(imageResource)
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
            
            // Name
            Text(name)
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    ProfileHeaderView(name: "Lucas",
                      imageResource: .profileAvatar)
}
