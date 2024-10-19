//
//  SleepProgressBarView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 12/10/2024.
//

import SwiftUI

public struct SleepProgressBarView: View {
    var progress: Float // Value between 0 and 1

    public var body: some View {
        ZStack(alignment: .leading) {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.darkBlueGray)
            
            // Progress fill
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.softPeriwinkle)
                .frame(width: CGFloat(progress) * 200) // Adjust width as per progress
        }
        .background(Color.darkBlueGray)
        .cornerRadius(12)
    }
}

#Preview {
    SleepProgressBarView(progress: 0.8)
}
