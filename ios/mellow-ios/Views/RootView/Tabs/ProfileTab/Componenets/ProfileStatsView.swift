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
                    .font(.main20)
                Text("Hours tracked")
                    .font(.main16)
                    .foregroundStyle(.slateGray)
            }
            VStack {
                Text("\(dayStreak)")
                    .font(.main20)
                Text("Day streak")
                    .font(.main16)
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
