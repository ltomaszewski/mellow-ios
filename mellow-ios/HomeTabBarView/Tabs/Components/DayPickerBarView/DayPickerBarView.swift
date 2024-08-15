//
//  DayPickerBarView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 13/08/2024.
//

import SwiftUI

struct DayPickerBarView: View {
    @Binding var date: Date?
    
    var body: some View {
        VStack {
            DayPickerBarViewRepresentable(selectedDate: $date)
                .frame(height: 44)
        }
    }
}

#Preview {
    DayPickerBarView(date: .init(get: { .now },
                                 set: { _ in }))
}
