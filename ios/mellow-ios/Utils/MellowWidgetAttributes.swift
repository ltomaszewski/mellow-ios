//
//  MellowWidgetAttributes.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 03/01/2025.
//

import Foundation
import ActivityKit

struct MellowWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var name: String
        var startDate: Date
        var expectedEndDate: Date
    }

    var title: String
}
