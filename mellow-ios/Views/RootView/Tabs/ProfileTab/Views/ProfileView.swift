//
//  ProfileView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 03/09/2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentDate: Date = Date()
    @State private var hoursTracked: Int = 0
    @State private var dayStreak: Int = 0
    @State private var name: String = ""
    @State private var imageResource: ImageResource = .kidoHim
    
    var body: some View {
        VStack(spacing: 24) {
            Rectangle()
                .foregroundStyle(.white.opacity(0.1))
                .frame(height: 1)
            
            // Profile Picture and Name
            ProfileHeaderView(name: $name,
                              imageResource: $imageResource)
            
            // Stats (Hours tracked and Day streak)
            ProfileStatsView(hoursTracked: hoursTracked,
                             dayStreak: dayStreak)
            
            // Calendar with Date and Highlighted Days
            ProfileCalendarView(currentDate: $currentDate,
                                highlightedDates: [23, 24, 25, 26, 28])
            .padding(.horizontal, 32)
            Spacer()
        }
        .background(Color.gunmetalBlue)
        .foregroundColor(.white)
        .onReceive(appState.databaseService.$dayStreak) { newValue in
            dayStreak = newValue
        }
        .onReceive(appState.databaseService.$hoursTracked) { newValue in
            hoursTracked = newValue
        }
        .onReceive(appState.databaseService.$kids) { newValue in
            guard let firstKid = newValue.first else { return }
            name = firstKid.name
            imageResource = .kidoHim
        }
    }
    
    func daysInMonth(date: Date) -> Int {
        let range = Calendar.current.range(of: .day, in: .month, for: date)!
        return range.count
    }
}

#Preview {
    ProfileView()
}
