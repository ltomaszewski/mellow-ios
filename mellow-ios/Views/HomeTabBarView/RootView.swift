//
//  HomeTabBarView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI

struct RootView: View {
    @StateObject var viewModel = RootViewModel()
    @State private var selectedItem = 2

    var body: some View {
        TabView(selection: $selectedItem,
                content:  {
            Group {
                TodayTabView()
                    .tabItem {
                        Label(viewModel.todayTabItem.name,
                              image: viewModel.todayTabItem.imageName)
                    }
                    .tag(viewModel.todayTabItem.tag)
                ScheduleTabView()
                    .tabItem {
                        Label(viewModel.scheduleTabItem.name,
                              image: viewModel.scheduleTabItem.imageName)
                    }
                    .tag(viewModel.scheduleTabItem.tag)
                ProfileTabView()
                    .tabItem {
                        Label(viewModel.profileTabItem.name,
                              image: viewModel.profileTabItem.imageName)
                    }
                    .tag(viewModel.profileTabItem.tag)
            }
            .toolbarBackground(.gunmetalBlue, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        })
    }
}
