//
//  DayPickerBarView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI

struct DayPickerBarView: View {
    @Binding var date: Date
    
    var body: some View {
        VStack {
            DayPickerBarViewRepresentable(date: $date)
                .frame(height: 44)
        }
        .onChange(of: date) { _, _ in /* For unknown reason the date change do not invoke updateUIView inside DayPickerBarViewRepresentable without it */}
    }
}

#Preview {
    DayPickerBarView(date: .init(get: { .now },
                                 set: { _ in }))
}
