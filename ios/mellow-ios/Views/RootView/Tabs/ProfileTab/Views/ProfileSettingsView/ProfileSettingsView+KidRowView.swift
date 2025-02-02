//
//  ProfileSettingsView+KidRowView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 10/11/2024.
//

import SwiftUI

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
