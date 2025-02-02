//
//  RootViewModel.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/08/2024.
//

import Foundation

final class RootViewModel: ObservableObject {
    enum TabItem: Hashable {
        case profile
        case today
        case schedule
        case learn
        
        var name: String {
            switch self {
            case .profile:
                return "Profile"
            case .today:
                return "Today"
            case .schedule:
                return "Schedule"
            case .learn:
                return "Learn"
            }
        }
        
        var imageName: String {
            switch self {
            case .profile:
                return "profile_tab"
            case .today:
                return "today_home"
            case .schedule:
                return "moon_tab"
            case .learn:
                return "learn_tab"
            }
        }
    }
}
