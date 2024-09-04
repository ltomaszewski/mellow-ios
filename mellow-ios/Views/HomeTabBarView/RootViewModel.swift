//
//  RootViewModel.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/08/2024.
//

import Foundation

final class RootViewModel: ObservableObject {
    struct TabItem {
        let name: String
        let imageName: String
        let tag: Int
    }
    
    let profileTabItem = TabItem(name: "Profile",
                                 imageName: "profile_tab",
                                 tag: 1)
    
    let todayTabItem = TabItem(name: "Today",
                               imageName: "today_home",
                               tag: 2)
    
    let scheduleTabItem = TabItem(name: "Schedule",
                                  imageName: "moon_tab",
                                  tag: 3)
}
