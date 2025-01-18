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
    @Binding var age: String // New binding for age
    
    var body: some View {
        VStack(spacing: 8) {
            // Profile Picture Placeholder
            Image(imageResource)
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
            
            // Name
            HStack(alignment: .bottom) {
                Text(name)
                    .font(.main18)
                    .fontWeight(.semibold)
//                Image(.arrowBottom)
//                    .renderingMode(.template)
//                    .tint(.white)
//                    .frame(width: 10, height: 15)
            }
            
            // Age
            Text(age) // Displaying the age
                .font(.main14)
                .foregroundColor(.slateGray)
        }
    }
}

#Preview {
    ProfileHeaderView(
        name: .init(get: { "Lucas" }, set: { _ in }),
        imageResource: .init(get: { .profileAvatar }, set: { _ in }),
        age: .init(get: { "3 years 6 months" }, set: { _ in }) // Example age
    )
    .preferredColorScheme(.dark)
}
