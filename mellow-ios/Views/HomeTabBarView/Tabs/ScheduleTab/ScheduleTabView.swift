//
//  SettingsTabView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/08/2024.
//

import SwiftUI

struct ScheduleTabView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Schedule view")
                .foregroundStyle(.white)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Making VStack full screen
        .background(.gunmetalBlue)
    }
}