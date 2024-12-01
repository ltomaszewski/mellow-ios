//
//  HomeTabBarView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI

struct RootView: View {
    @StateObject var viewModel = RootViewModel()
    @State var endSleepTriggered: Bool = false
    @State private var selectedItem: RootViewModel.TabItem = .schedule
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedItem,
                    content:  {
                Group {
                    TodayTabView(onNextSessionButtonTapped: {
                        print("Start next session")
                    })
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
}
