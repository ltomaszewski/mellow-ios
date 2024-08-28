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
                ProfileTabView()
                    .tabItem {
                        Label(viewModel.profileTabItem.name,
                              image: viewModel.profileTabItem.imageName)
                    }
                    .tag(viewModel.profileTabItem.tag)
                TodayTabView()
                    .tabItem {
                        Label(viewModel.todayTabItem.name,
                              image: viewModel.todayTabItem.imageName)
                    }
                    .tag(viewModel.todayTabItem.tag)
                SettingsTabView()
                    .tabItem {
                        Label(viewModel.settingsTabItem.name,
                              image: viewModel.settingsTabItem.imageName)
                    }
                    .tag(viewModel.settingsTabItem.tag)
            }
            .toolbarBackground(.gunmetalBlue, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        })
    }
}
