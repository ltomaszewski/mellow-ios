//
//  ProfileStatsView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 03/09/2024.
//

import SwiftUI

struct ProfileStatsView: View {
    var hoursTracked: Int
    var dayStreak: Int
    
    var body: some View {
        HStack(spacing: 40) {
            VStack {
                Text("\(hoursTracked)")
                    .fontWeight(.semibold)
                Text("Hours tracked")
                    .font(.caption)
                    .foregroundStyle(.slateGray)
            }
            VStack {
                Text("\(dayStreak)")
                    .fontWeight(.semibold)
                Text("Day streak")
                    .font(.caption)
                    .foregroundStyle(.slateGray)
            }
        }
    }
}

#Preview {
    VStack {
        ProfileStatsView(
            hoursTracked: 13535,
            dayStreak: 3)
        .foregroundStyle(.white)
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.gunmetalBlue)
}
