//
//  SleepScoreLockedView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 02/12/2024.
//

import SwiftUI

struct SleepScoreLockedView: View {
    var body: some View {
        VStack {
            // Top text: "Sleep score locked"
            Text("Sleep score locked")
                .font(.main14)
                .foregroundColor(.slateGray)

            // Bottom text: "Complete at least one day of sleep to unlock sleep score"
            Text("Complete at least two days of sleep to unlock sleep score")
                .font(.main18)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity) // Adjust height to fit the content
        .padding(.vertical, 64)
        .padding(.horizontal, 32)
        .background(.darkBlueGray)
        .cornerRadius(12)
    }
}

#Preview {
    SleepScoreLockedView()
}
