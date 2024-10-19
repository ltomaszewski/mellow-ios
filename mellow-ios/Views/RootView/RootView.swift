//
//  HomeTabBarView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI

struct RootView: View {
    @StateObject var viewModel = RootViewModel()
    @State private var selectedItem: RootViewModel.TabItem = .schedule

    var body: some View {
        TabView(selection: $selectedItem,
                content:  {
            Group {
                TodayTabView(progress: 0.3,
                             totalAsleep: 4.5,
                             sleepgoal: 11,
                             nextSleep: 30,
                             scoreSleep: 86,
                             scoreSleepMark: "Great",
                             napTimeScore: 86,
                             sleepDurationScore: 86,
                             wakeupTimeScore: 86,
                             treeDayConsistencyScore: 86)
                    .tabItem {
                        Label(RootViewModel.TabItem.today.name,
                              image: RootViewModel.TabItem.today.imageName)
                        .font(.main12)
                    }
                    .tag(RootViewModel.TabItem.today)
                ScheduleTabView()
                    .tabItem {
                        Label(RootViewModel.TabItem.schedule.name,
                              image: RootViewModel.TabItem.schedule.imageName)
                        .font(.main12)
                    }
                    .tag(RootViewModel.TabItem.schedule)
                ProfileTabView()
                    .tabItem {
                        Label(RootViewModel.TabItem.profile.name,
                              image: RootViewModel.TabItem.profile.imageName)
                        .font(.main12)
                    }
                    .tag(RootViewModel.TabItem.profile)
            }
            .toolbarBackground(.gunmetalBlue, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        })
    }
}
