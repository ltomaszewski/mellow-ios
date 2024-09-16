//
//  DayHourSlotView.swift
//  mellow-ios
//
//  Created by Lukasz Tomaszewski on 14/08/2024.
//

import SwiftUI

struct DayHourSlotView: View {
    let date: Date

    var body: some View {
        ZStack {
            HStack {
                VStack {
                    HourTimeView(date: date)
                    Spacer()
                }
                .frame(width: 64)
                Spacer(minLength: 16)
                ZStack {
                    VStack {
                        CalendarSeparator()
                        Spacer()
                    }
                }
            }
        }
    }
}
