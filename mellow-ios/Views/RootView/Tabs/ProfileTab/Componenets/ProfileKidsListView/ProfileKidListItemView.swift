//
//  ProfileKidListItemView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 09/11/2024.
//

import SwiftUI

struct ProfileKidListItemView: View {
    let kid: ProfileKidsListView.Kid
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(kid.imageResource)
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
            
            if isSelected {
                Image(.checkMark)
                    .resizable()
                    .frame(width: 18, height: 13)
            }
        }
        .padding(16)
    }
}

extension ProfileKidsListView {
    struct Kid: Hashable {
        let name: String
        let ageFormatted: String
        let imageResource: ImageResource
        let databaseKidsID: String
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(databaseKidsID)
            hasher.combine(name)
        }
    }
}

#Preview {
    ProfileKidListItemView(kid: .init(name: "Lukasz",
                                      ageFormatted: "3 years 6 months",
                                      imageResource: .kidoHim,
                                      databaseKidsID: "1"),
                           isSelected: true)
    .background(Color.midnightBlue)
}
