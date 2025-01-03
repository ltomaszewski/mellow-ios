//
//  mellow_widgetBundle.swift
//  mellow-widget
//
//  Created by Lukasz Tomaszewski on 03/01/2025.
//

import WidgetKit
import SwiftUI

@main
struct mellow_widgetBundle: WidgetBundle {
    var body: some Widget {
        MellowWidget()
        mellow_widgetControl()
        MellowWidgetLiveActivity()
    }
}
