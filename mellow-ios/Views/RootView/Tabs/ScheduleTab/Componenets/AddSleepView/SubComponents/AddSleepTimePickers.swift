//
//  SleepTimePickers.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 28/09/2024.
//

import SwiftUI

extension AddSleepView {
    struct TimePickers: View {
        @Binding var startTime: Date?
        @Binding var startTimeMin: Date
        @Binding var startTimeMax: Date

        @Binding var endTime: Date?
        @Binding var endTimeMin: Date
        @Binding var endTimeMax: Date

        @Binding var startTimePickerVisible: Bool
        @Binding var endTimePickerVisible: Bool
        @Binding var width: CGFloat

        var body: some View {
            VStack(spacing: 16) {
                CalendarSeparator()
                SleepTimePicker(
                    text: "Start Time",
                    date: $startTime,
                    minDate: $startTimeMin,
                    maxDate: $startTimeMax,
                    isDatePickerVisible: $startTimePickerVisible,
                    width: $width
                )
                .padding(.horizontal, 16)

                CalendarSeparator()

                SleepTimePicker(
                    text: "End Time",
                    date: $endTime,
                    minDate: $endTimeMin,
                    maxDate: $endTimeMax,
                    isDatePickerVisible: $endTimePickerVisible,
                    width: $width
                )
                .padding(.horizontal, 16)
            }
            .onChange(of: startTimePickerVisible) { oldValue, newValue in
                if endTimePickerVisible, !oldValue, newValue {
                    endTimePickerVisible = false
                }
            }
            .onChange(of: endTimePickerVisible) { oldValue, newValue in
                if startTimePickerVisible, !oldValue, newValue {
                    startTimePickerVisible = false
                }
            }
        }
    }
}
