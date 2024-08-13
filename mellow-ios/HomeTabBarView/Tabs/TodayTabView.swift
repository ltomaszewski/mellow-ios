//
//  TodayTabView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI

struct TodayTabView: View {
    @State var day: Date? = Date.now.adjustToMidday()

    var body: some View {
        VStack {
            DayPickerBarView(date: $day)
                .frame(height: 64)
            Text("Verticla calendar preview")
            Spacer()
        }
    }
}

#Preview {
    TodayTabView()
}
